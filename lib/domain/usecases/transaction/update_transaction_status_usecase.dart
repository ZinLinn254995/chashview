// lib/domain/usecases/transaction/update_transaction_status_usecase.dart (Admin)
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class UpdateTransactionStatusUseCase {
  final TransactionRepository repository;

  UpdateTransactionStatusUseCase(this.repository);

  Future<void> call({
    required String transactionId,
    required TransactionStatus status,
    String? notes,
  }) async {
    return await repository.updateTransactionStatus(
      transactionId: transactionId,
      status: status,
      notes: notes,
    );
  }
}