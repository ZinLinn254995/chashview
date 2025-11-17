import '../../entities/income_entity.dart';
import '../../repositories/income_repository.dart';

class UpdateIncomeUseCase {
  final IncomeRepository repository;

  UpdateIncomeUseCase(this.repository);

  Future<void> call(String userId, IncomeEntity income) async {
    return repository.updateIncome(userId, income);
  }
}
