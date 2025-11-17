import '../../domain/entities/income_entity.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/income_remote_data_source.dart';
import '../models/income_model.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDataSource remoteDataSource;

  IncomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createIncome(String userId, IncomeEntity income) async {
    final model = IncomeModel(
      id: income.id,
      titleId: income.titleId,
      amount: income.amount,
      categoryId: income.categoryId,
      date: income.date,
      createdAt: income.createdAt,
      isBookmarked: income.isBookmarked,
    );
    await remoteDataSource.createIncome(userId, model);
  }

  @override
  Future<List<IncomeEntity>> getIncomes(String userId) async {
    final models = await remoteDataSource.getIncomes(userId);
    return models;
  }

  @override
  Future<void> updateIncome(String userId, IncomeEntity income) async {
    final model = IncomeModel(
      id: income.id,
      titleId: income.titleId,
      amount: income.amount,
      categoryId: income.categoryId,
      date: income.date,
      createdAt: income.createdAt,
      isBookmarked: income.isBookmarked,
    );
    await remoteDataSource.updateIncome(userId, model);
  }

  @override
  Future<void> deleteIncome(String userId, String incomeId) async {
    await remoteDataSource.deleteIncome(userId, incomeId);
  }
}
