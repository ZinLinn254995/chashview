import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../domain/entities/category_entity.dart';
import '../../core/constants/firebase_paths.dart';
import '../../domain/entities/title_entity.dart';
import '../../domain/usecases/category/create_category_usecase.dart';
import '../../domain/usecases/category/get_categories_usecase.dart';
import '../../domain/usecases/category/update_category_usecase.dart';
import '../../domain/usecases/category/delete_category_usecase.dart';
import '../../domain/usecases/category/listen_categories_usecase.dart';
import 'auth_viewmodel.dart';

class CategoryViewModel extends ChangeNotifier {
  final CreateCategoryUseCase createCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final ListenCategoriesUseCase listenCategoriesUseCase;
  final AuthViewModel authViewModel;

  // 🔥 ၁။ List နှစ်ခု သီးသန့်ခွဲထားခြင်း
  List<CategoryEntity> incomeCategories = [];
  List<CategoryEntity> expenseCategories = [];

  bool isLoading = false;

  // Streams for listening
  StreamSubscription<List<CategoryEntity>>? _incomeSub;
  StreamSubscription<List<CategoryEntity>>? _expenseSub;

  CategoryViewModel({
    required this.createCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.listenCategoriesUseCase,
    required this.authViewModel,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
    // App စစချင်း User ရှိနေရင် Listen စလုပ်ပါ
    if (authViewModel.user != null) {
      _initStreams();
    }
  }

  void _handleUserChanged() {
    if (authViewModel.user == null) {
      // User logout လုပ်သွားရင် Data ရှင်းပြီး Stream ရပ်မယ်
      incomeCategories = [];
      expenseCategories = [];
      _cancelStreams();
      notifyListeners();
    } else {
      // User login ဝင်လာရင် Stream စဖွင့်မယ်
      _initStreams();
    }
  }

  // 🔥 ၂။ Income ရော Expense ရော တပြိုင်နက် Listen လုပ်ခြင်း
  void _initStreams() {
    _cancelStreams(); // အဟောင်းရှိရင် အရင်ဖြတ်

    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    // Listen to Income Categories
    _incomeSub = listenCategoriesUseCase.call(uid, 'income').listen(
            (list) {
          incomeCategories = list;
          isLoading = false; // Data ရောက်လာရင် loading ပိတ်
          notifyListeners();
        },
        onError: (e) {
          debugPrint("Income Stream Error: $e");
        }
    );

    // Listen to Expense Categories
    _expenseSub = listenCategoriesUseCase.call(uid, 'expense').listen(
            (list) {
          expenseCategories = list;
          isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          debugPrint("Expense Stream Error: $e");
        }
    );
  }

  void _cancelStreams() {
    _incomeSub?.cancel();
    _expenseSub?.cancel();
    _incomeSub = null;
    _expenseSub = null;
  }

  // 🔥 ၃။ UI ကနေ Type အလိုက် Data လိုချင်ရင် ခေါ်သုံးရန် Helper
  List<CategoryEntity> getCategoriesByType(String type) {
    if (type == 'income') {
      return incomeCategories;
    } else if (type == 'expense') {
      return expenseCategories;
    }
    return [];
  }

  /// CRUD Operations (Type ထည့်ပေးရမည်)

  Future<void> addCategory(String type, String name) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    // Validation: Check duplicates in the specific list
    final targetList = type == 'income' ? incomeCategories : expenseCategories;
    final exists = targetList.any((c) => c.name.toLowerCase() == name.toLowerCase());

    if (exists) return;

    final newId = FirebaseDatabase.instance.ref().push().key!;
    final now = DateTime.now();

    final newCategory = CategoryEntity(
      id: newId,
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    await createCategoryUseCase.call(uid, type, newCategory);
    // Stream က auto update လုပ်ပေးမှာမို့ loadCategories ပြန်ခေါ်စရာမလိုပါ
  }

  Future<void> editCategory(String type, String categoryId, String newName) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    final targetList = type == 'income' ? incomeCategories : expenseCategories;

    CategoryEntity? existing;
    try {
      existing = targetList.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return;
    }

    final updated = existing.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );

    await updateCategoryUseCase.call(uid, type, updated);
  }

  Future<void> removeCategory(String type, String id) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;
    await deleteCategoryUseCase.call(uid, type, id);
  }


  /*Future<void> deleteCategoryWithCascade({
    required String type,
    required String categoryId,
    required List<TitleEntity> relatedTitles,
    required List<String> relatedItemIds,
  }) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final dbRef = FirebaseDatabase.instance.ref();

      // Debug prints
      debugPrint("=== Starting Cascade Delete ===");
      debugPrint("User UID: $uid");
      debugPrint("Category ID: $categoryId");
      debugPrint("Type: $type");
      debugPrint("Titles to delete: ${relatedTitles.length}");
      debugPrint("Items to delete: ${relatedItemIds.length}");

      // ၁။ Related Items (Income/Expense) များကို ဖျက်ခြင်း
      final String itemRoot = type == 'income' ? 'income' : 'expense';

      for (var itemId in relatedItemIds) {
        final itemPath = 'users/$uid/$itemRoot/$itemId';
        debugPrint("Deleting item at: $itemPath");
        await dbRef.child('users').child(uid).child(itemRoot).child(itemId).remove();
      }

      // ၂။ Related Titles များကို ဖျက်ခြင်း
      final String titleRoot = type == 'income' ? 'incomeTitles' : 'expenseTitles';

      for (var title in relatedTitles) {
        final titlePath = 'users/$uid/$titleRoot/${title.id}';
        debugPrint("Deleting title at: $titlePath");
        await dbRef.child('users').child(uid).child(titleRoot).child(title.id).remove();
      }

      // ၃။ Category ကို ဖျက်ခြင်း
      final categoryPath = 'users/$uid/categories/$type/$categoryId';
      debugPrint("Deleting category at: $categoryPath");
      await dbRef.child('users').child(uid).child('categories').child(type).child(categoryId).remove();

      debugPrint("=== Cascade Delete Completed Successfully ===");

    } catch (e, stackTrace) {
      debugPrint("Cascading Delete Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      // Error ကို rethrow လုပ်ပါ
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }*/

  Future<void> deleteCategoryWithCascade({
    required String type,
    required String categoryId,
    required List<TitleEntity> relatedTitles,
    required List<String> relatedItemIds,
  }) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final dbRef = FirebaseDatabase.instance.ref();

      Map<String, dynamic> updates = {};

      // ၁။ Items များကို ဖျက်ရန်
      final String itemPath = type == 'income'
          ? FirebasePaths.income(uid)
          : FirebasePaths.expense(uid);

      for (var itemId in relatedItemIds) {
        updates['$itemPath/$itemId'] = null;
      }

      // ၂။ Titles များကို ဖျက်ရန်
      final String titlePath = 'users/$uid/${type}Titles';

      for (var title in relatedTitles) {
        updates['$titlePath/${title.id}'] = null;
      }

      // ၃။ Category ကို ဖျက်ရန်
      final String categoryPath = 'users/$uid/categories/$type/$categoryId';
      updates[categoryPath] = null;

      // ၄။ Batch update လုပ်ခြင်း
      debugPrint("Batch updates: $updates");
      await dbRef.update(updates);

      debugPrint("=== Batch Delete Completed Successfully ===");

    } catch (e, stackTrace) {
      debugPrint("Batch Delete Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancelStreams();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}