import 'package:flutter/foundation.dart';
import '../../../domain/entities/category_entity.dart';
import '../../domain/usecases/category/create_category_usecase.dart';
import '../../domain/usecases/category/get_categories_usecase.dart';
import '../../domain/usecases/category/update_category_usecase.dart';
import '../../domain/usecases/category/delete_category_usecase.dart';
import 'auth_viewmodel.dart';

class CategoryViewModel extends ChangeNotifier {
  final CreateCategoryUseCase createCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final AuthViewModel authViewModel;

  List<CategoryEntity> categories = [];
  bool isLoading = false;

  String? _currentType;  // user last type

  CategoryViewModel({
    required this.createCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.authViewModel,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    categories = [];
    notifyListeners();
    if (_currentType != null) loadCategories(_currentType!);
  }

  Future<void> loadCategories(String type) async {
    _currentType = type;
    final userId = authViewModel.user?.uid;
    if (userId == null) {
      categories = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    categories = await getCategoriesUseCase.call(userId, type);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(String type, String name) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    final exists = categories.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (exists) return;

    await createCategoryUseCase.call(
      userId,
      type,
      CategoryEntity(id: '', name: name),
    );

    await loadCategories(type);
  }

  /// Update a category (using copyWith for immutability)
  Future<void> editCategory(String type, String categoryId, String newName) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    final existing = categories.firstWhere((c) => c.id == categoryId);
    final updated = existing.copyWith(name: newName);

    await updateCategoryUseCase.call(userId, type, updated);
    await loadCategories(type);
  }

  Future<void> removeCategory(String type, String id) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await deleteCategoryUseCase.call(userId, type, id);
    await loadCategories(type);
  }
}
