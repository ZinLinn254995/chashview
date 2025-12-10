// lib/domain/usecases/transaction/get_transactions_usecase.dart (Admin)
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call({
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getTransactions(
      userId: userId,
      type: type,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}