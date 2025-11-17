import '../../../core/services/firebase_service.dart';
import '../../../core/constants/firebase_paths.dart';
import '../models/expense_model.dart';

class ExpenseRemoteDataSource {
  final FirebaseService firebaseService;

  ExpenseRemoteDataSource(this.firebaseService);

  Future<void> createExpense(String userId, ExpenseModel model) async {
    await firebaseService.ref('${FirebasePaths.expense(userId)}/${model.id}').set(model.toJson());
  }

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final snapshot = await firebaseService.getData(FirebasePaths.expense(userId));

    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.entries.map((e) {
      return ExpenseModel.fromJson(
        Map<String, dynamic>.from(e.value),
        e.key,
      );
    }).toList();
  }

  Future<void> updateExpense(String userId, ExpenseModel model) async {
    await firebaseService.ref('${FirebasePaths.expense(userId)}/${model.id}').update(model.toJson());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await firebaseService.ref('${FirebasePaths.expense(userId)}/$expenseId').remove();
  }
}
