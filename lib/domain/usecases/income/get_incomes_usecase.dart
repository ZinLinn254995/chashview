import '../../entities/income_entity.dart';
import '../../repositories/income_repository.dart';

class GetIncomesUseCase {
  final IncomeRepository repository;

  GetIncomesUseCase(this.repository);

  Future<List<IncomeEntity>> call(String userId) async {
    return repository.getIncomes(userId);
  }
}
