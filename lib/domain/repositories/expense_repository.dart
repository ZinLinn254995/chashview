import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<void> createExpense(String userId, ExpenseEntity expense);
  Future<List<ExpenseEntity>> getExpenses(String userId);
  Future<void> updateExpense(String userId, ExpenseEntity expense);
  Future<void> deleteExpense(String userId, String expenseId);
}
