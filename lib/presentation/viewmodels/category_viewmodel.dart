import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../domain/entities/category_entity.dart';
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

  @override
  void dispose() {
    _cancelStreams();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}