// lib/domain/repositories/transaction_repository.dart
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(TransactionEntity transaction);
  Future<List<TransactionEntity>> getTransactions({
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<TransactionEntity>> getTransactionsByUser(String userId);
  Future<TransactionEntity?> getTransactionById(String transactionId);
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? notes,
  });
  Future<TransactionEntity?> getLastPendingBnplTransaction(String userId);
}