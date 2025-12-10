// lib/domain/usecases/transaction/get_user_transactions_usecase.dart
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class GetUserTransactionsUseCase {
  final TransactionRepository repository;

  GetUserTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call(String userId) async {
    return await repository.getTransactionsByUser(userId);
  }
}