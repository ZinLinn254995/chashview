// lib/data/repositories/transaction_repository_impl.dart
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    await remoteDataSource.createTransaction(transaction);
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDataSource.getTransactions(
      userId: userId,
      type: _typeToString(type),
      status: _statusToString(status),
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByUser(String userId) async {
    return await remoteDataSource.getTransactionsByUser(userId);
  }

  @override
  Future<TransactionEntity?> getTransactionById(String transactionId) async {
    return await remoteDataSource.getTransactionById(transactionId);
  }

  @override
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? notes,
  }) async {
    await remoteDataSource.updateTransactionStatus(
      transactionId: transactionId,
      status: _statusToStringRequired(status),
      notes: notes,
    );
  }

  // =======================================================
  // 🔥 NEW IMPLEMENTATION FOR BNPL DEBT LOGIC
  // =======================================================
  @override
  Future<TransactionEntity?> getLastPendingBnplTransaction(String userId) async {
    // 💡 RemoteDataSource တွင် corresponding method ကို ခေါ်ယူရန်
    return await remoteDataSource.getLastPendingBnplTransaction(
      userId: userId,
      type: _typeToString(TransactionType.subscription), // BNPL ကို Subscription Type အဖြစ် မှတ်တမ်းတင်ထားသည်ဟု ယူဆခြင်း
      status: _statusToString(TransactionStatus.pending), // Pending Status ကို ရှာဖွေခြင်း
    );
  }

  // Helper methods to convert enum to string
  String? _typeToString(TransactionType? type) {
    return type?.toString().split('.').last;
  }

  String? _statusToString(TransactionStatus? status) {
    return status?.toString().split('.').last;
  }

  // 🔥 NEW: Required status conversion (not nullable)
  String _statusToStringRequired(TransactionStatus status) {
    return status.toString().split('.').last;
  }
}