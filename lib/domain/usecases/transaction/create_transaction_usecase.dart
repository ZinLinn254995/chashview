// lib/domain/usecases/transaction/create_transaction_usecase.dart
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<void> call(TransactionEntity transaction) async {
    return await repository.createTransaction(transaction);
  }
}