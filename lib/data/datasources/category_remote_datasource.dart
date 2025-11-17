import '../../../core/services/firebase_service.dart';
import '../models/category_model.dart';
import '../../../core/constants/firebase_paths.dart';

class CategoryRemoteDataSource {
  final FirebaseService firebaseService;

  CategoryRemoteDataSource(this.firebaseService);

  /// Create new category
  Future<void> createCategory(
      String userId, String type, CategoryModel category) async {
    final ref = firebaseService.ref('${FirebasePaths.categories(userId)}/$type').push();
    final timestamp = DateTime.now();
    await ref.set({
      ...category.toJson(),
      'createdAt': timestamp.toIso8601String(),
      'updatedAt': timestamp.toIso8601String(),
    });
  }

  /// Read all categories of a type
  Future<List<CategoryModel>> getCategories(String userId, String type) async {
    final ref = firebaseService.ref('${FirebasePaths.categories(userId)}/$type');
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];

    return snapshot.children.map((data) {
      final json = Map<String, dynamic>.from(data.value as Map);
      return CategoryModel.fromJson(json, data.key!);
    }).toList();
  }

  /// Update existing category
  Future<void> updateCategory(String userId, String type, CategoryModel category) async {
    final ref = firebaseService.ref('${FirebasePaths.categories(userId)}/$type/${category.id}');
    await ref.update({
      ...category.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Delete category
  Future<void> deleteCategory(String userId, String type, String categoryId) async {
    final ref = firebaseService.ref('${FirebasePaths.categories(userId)}/$type/$categoryId');
    await ref.remove();
  }

  /// Listen to realtime changes
  Stream<List<CategoryModel>> listenToCategories(String userId, String type) {
    final ref = firebaseService.ref('${FirebasePaths.categories(userId)}/$type');
    return ref.onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return [];

      return snapshot.children.map((data) {
        final json = Map<String, dynamic>.from(data.value as Map);
        return CategoryModel.fromJson(json, data.key!);
      }).toList();
    });
  }
}
