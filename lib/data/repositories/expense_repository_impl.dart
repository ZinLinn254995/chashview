import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createExpense(String userId, ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      titleId: expense.titleId,
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: expense.date,
      createdAt: expense.createdAt,
      isBookmarked: expense.isBookmarked,
    );

    await remoteDataSource.createExpense(userId, model);
  }

  @override
  Future<List<ExpenseEntity>> getExpenses(String userId) async {
    return await remoteDataSource.getExpenses(userId);
  }

  @override
  Future<void> updateExpense(String userId, ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      titleId: expense.titleId,
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: expense.date,
      createdAt: expense.createdAt,
      isBookmarked: expense.isBookmarked,
    );

    await remoteDataSource.updateExpense(userId, model);
  }

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {
    await remoteDataSource.deleteExpense(userId, expenseId);
  }
}
