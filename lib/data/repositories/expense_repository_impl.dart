import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.remoteDataSource);

  ExpenseModel _toModel(ExpenseEntity e) {
    return ExpenseModel(
      id: e.id,
      titleId: e.titleId,
      amount: e.amount,
      date: e.date,
      createdAt: e.createdAt,
    );
  }

  @override
  Future<void> createExpense(String userId, ExpenseEntity e) async {
    await remoteDataSource.createExpense(userId, _toModel(e));
  }

  @override
  Future<List<ExpenseEntity>> getExpenses(String userId) async {
    return await remoteDataSource.getExpenses(userId);
  }

  @override
  Future<void> updateExpense(String userId, ExpenseEntity e) async {
    await remoteDataSource.updateExpense(userId, _toModel(e));
  }

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {
    await remoteDataSource.deleteExpense(userId, expenseId);
  }

  /// 🔥 REALTIME
  @override
  Stream<List<ExpenseEntity>> listenExpenses(String userId) {
    return remoteDataSource.listenExpenses(userId)
        .map<List<ExpenseEntity>>((list) => list);
  }
}
