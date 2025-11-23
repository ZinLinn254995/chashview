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

  List<CategoryEntity> categories = [];
  bool isLoading = false;

  String? _currentType;
  StreamSubscription<List<CategoryEntity>>? _sub;
  bool _isListening = false;

  CategoryViewModel({
    required this.createCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.listenCategoriesUseCase,
    required this.authViewModel,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    categories = [];
    notifyListeners();
    if (_currentType != null) _subscribe(_currentType!);
  }

  void _subscribe(String type) {
    _sub?.cancel();
    _sub = null;
    _isListening = false;

    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    _sub = listenCategoriesUseCase.call(uid, type).listen(
          (list) {
        categories = list;
        _isListening = true;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isListening = false;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadCategories(String type) async {
    _currentType = type;
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    categories = await getCategoriesUseCase.call(uid, type);

    isLoading = false;
    notifyListeners();
  }

  /// 🔥 Fixed: auto-generate id and timestamp
  Future<void> addCategory(String type, String name) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    final exists = categories.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (exists) return;

    // Auto-generate Firebase key
    final newId = FirebaseDatabase.instance.ref().push().key!;
    final now = DateTime.now();

    final newCategory = CategoryEntity(
      id: newId,
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    await createCategoryUseCase.call(uid, type, newCategory);

    if (!_isListening) await loadCategories(type);
  }

  Future<void> editCategory(String type, String categoryId, String newName) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    CategoryEntity? existing;
    try {
      existing = categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      // Category not found, just return
      return;
    }

    final updated = existing.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );

    await updateCategoryUseCase.call(uid, type, updated);

    if (!_isListening) await loadCategories(type);
  }


  Future<void> removeCategory(String type, String id) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await deleteCategoryUseCase.call(uid, type, id);

    if (!_isListening) await loadCategories(type);
  }

  @override
  void dispose() {
    _sub?.cancel();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}
