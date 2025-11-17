import 'package:firebase_database/firebase_database.dart';
import '../../../core/services/firebase_service.dart';
import '../models/income_model.dart';
import '../../../core/constants/firebase_paths.dart';

class IncomeRemoteDataSource {
  final FirebaseService firebaseService;

  IncomeRemoteDataSource(this.firebaseService);

  /// Create new income
  Future<void> createIncome(String userId, IncomeModel income) async {
    final ref = firebaseService.ref(FirebasePaths.income(userId)).push();
    await ref.set(income.toJson());
  }

  /// Get all incomes
  Future<List<IncomeModel>> getIncomes(String userId) async {
    final ref = firebaseService.ref(FirebasePaths.income(userId));
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];

    return snapshot.children.map((data) {
      final json = Map<String, dynamic>.from(data.value as Map);
      return IncomeModel.fromJson(json, data.key!);
    }).toList();
  }

  /// Update income
  Future<void> updateIncome(String userId, IncomeModel income) async {
    final ref = firebaseService.ref('${FirebasePaths.income(userId)}/${income.id}');
    await ref.update(income.toJson());
  }

  /// Delete income
  Future<void> deleteIncome(String userId, String incomeId) async {
    final ref = firebaseService.ref('${FirebasePaths.income(userId)}/$incomeId');
    await ref.remove();
  }
}
