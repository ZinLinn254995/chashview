import '../../repositories/income_repository.dart';

class DeleteIncomeUseCase {
  final IncomeRepository repository;

  DeleteIncomeUseCase(this.repository);

  Future<void> call(String userId, String incomeId) async {
    return repository.deleteIncome(userId, incomeId);
  }
}
