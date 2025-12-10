// lib/domain/usecases/transaction/get_transaction_by_id_usecase.dart
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionByIdUseCase {
  final TransactionRepository repository;

  GetTransactionByIdUseCase(this.repository);

  Future<TransactionEntity?> call(String transactionId) async {
    return await repository.getTransactionById(transactionId);
  }
}