// lib/presentation/viewmodels/transaction_viewmodel.dart (updated)
import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/transaction/get_transactions_usecase.dart';
import '../../domain/usecases/transaction/get_user_transactions_usecase.dart';
import '../../domain/usecases/transaction/create_transaction_usecase.dart';
import '../../domain/usecases/transaction/get_transaction_by_id_usecase.dart';
import '../../domain/usecases/transaction/update_transaction_status_usecase.dart';

class TransactionViewModel extends ChangeNotifier {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetUserTransactionsUseCase getUserTransactionsUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final GetTransactionByIdUseCase getTransactionByIdUseCase;
  final UpdateTransactionStatusUseCase updateTransactionStatusUseCase;

  List<TransactionEntity> _transactions = [];
  List<TransactionEntity> get transactions => _transactions;

  TransactionEntity? _selectedTransaction;
  TransactionEntity? get selectedTransaction => _selectedTransaction;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  TransactionViewModel({
    required this.getTransactionsUseCase,
    required this.getUserTransactionsUseCase,
    required this.createTransactionUseCase,
    required this.getTransactionByIdUseCase,
    required this.updateTransactionStatusUseCase,
  });

  // 🔥 Update transaction status (Admin)
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await updateTransactionStatusUseCase.call(
        transactionId: transactionId,
        status: status,
        notes: notes,
      );

      _successMessage = 'Transaction status updated successfully';

      // Local list ထဲမှာ update လုပ်ခြင်း
      final index = _transactions.indexWhere((t) => t.transactionId == transactionId);
      if (index != -1) {
        final updatedTransaction = _transactions[index].copyWith(
          status: status,
          notes: notes ?? _transactions[index].notes,
        );
        _transactions[index] = updatedTransaction;
      }

      // Selected transaction ကိုလည်း update လုပ်ခြင်း
      if (_selectedTransaction?.transactionId == transactionId) {
        _selectedTransaction = _selectedTransaction!.copyWith(
          status: status,
          notes: notes ?? _selectedTransaction!.notes,
        );
      }

    } catch (e) {
      _errorMessage = 'Failed to update transaction status: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔥 Get single transaction by ID
  Future<TransactionEntity?> loadTransactionById(String transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTransaction = await getTransactionByIdUseCase.call(transactionId);
      return _selectedTransaction;
    } catch (e) {
      _errorMessage = 'Failed to load transaction: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User: Get their own transactions
  Future<void> loadUserTransactions(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await getUserTransactionsUseCase.call(userId);
    } catch (e) {
      _errorMessage = 'Failed to load transactions: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Admin: Get all transactions with filters
  Future<void> loadAllTransactions({
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await getTransactionsUseCase.call(
        userId: userId,
        type: type,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _errorMessage = 'Failed to load transactions: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create new transaction
  Future<void> createTransaction(TransactionEntity transaction) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await createTransactionUseCase.call(transaction);
      _successMessage = 'Transaction created successfully';

      // Create လုပ်ပြီးရင် list ကို refresh လုပ်ခြင်း (optional)
      if (transaction.userId.isNotEmpty) {
        await loadUserTransactions(transaction.userId);
      }
    } catch (e) {
      _errorMessage = 'Failed to create transaction: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔥 Filter transactions by type
  List<TransactionEntity> getTransactionsByType(TransactionType type) {
    return _transactions.where((transaction) => transaction.type == type).toList();
  }

  // 🔥 Filter transactions by status
  List<TransactionEntity> getTransactionsByStatus(TransactionStatus status) {
    return _transactions.where((transaction) => transaction.status == status).toList();
  }

  // 🔥 Get total amount by type
  double getTotalAmountByType(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // 🔥 Get top-up code transactions (specific helper)
  List<TransactionEntity> getTopUpCodeTransactions() {
    return getTransactionsByType(TransactionType.topUpCode);
  }

  // 🔥 Get subscription transactions (specific helper)
  List<TransactionEntity> getSubscriptionTransactions() {
    return getTransactionsByType(TransactionType.subscription);
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedTransaction = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 🔥 Get transaction by reference ID (top-up code, invoice, etc.)
  TransactionEntity? getTransactionByReferenceId(String referenceId) {
    return _transactions.firstWhere(
          (transaction) => transaction.referenceId == referenceId,
      orElse: () => throw Exception('Transaction not found'),
    );
  }
}