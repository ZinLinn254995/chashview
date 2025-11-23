import '../../entities/income_entity.dart';
import '../../repositories/income_repository.dart';

class ListenIncomesUseCase {
  final IncomeRepository repository;

  ListenIncomesUseCase(this.repository);

  Stream<List<IncomeEntity>> call(String userId) {
    return repository.listenIncomes(userId);
  }
}
