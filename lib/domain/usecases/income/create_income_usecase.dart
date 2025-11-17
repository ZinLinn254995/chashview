import '../../entities/income_entity.dart';
import '../../repositories/income_repository.dart';

class CreateIncomeUseCase {
  final IncomeRepository repository;

  CreateIncomeUseCase(this.repository);

  Future<void> call(String userId, IncomeEntity income) async {
    return repository.createIncome(userId, income);
  }
}
