import '../entities/income_entity.dart';

abstract class IncomeRepository {
  Future<void> createIncome(String userId, IncomeEntity income);
  Future<List<IncomeEntity>> getIncomes(String userId);
  Future<void> updateIncome(String userId, IncomeEntity income);
  Future<void> deleteIncome(String userId, String incomeId);
}
