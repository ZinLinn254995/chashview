// lib/data/datasources/transaction_remote_data_source.dart
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class TransactionRemoteDataSource {
  Future<void> createTransaction(TransactionEntity transaction);

  // 🔥 Parameters changed to String? (not enums)
  Future<List<TransactionEntity>> getTransactions({
    String? userId,
    String? type,      // String for database query
    String? status,    // String for database query
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<TransactionEntity>> getTransactionsByUser(String userId);
  Future<TransactionEntity?> getTransactionById(String transactionId);

  Future<void> updateTransactionStatus({
    required String transactionId,
    required String status,  // String for database
    String? notes,
  });

  // 🔥 NEW: Abstract method for BNPL Logic
  Future<TransactionEntity?> getLastPendingBnplTransaction({
    required String userId,
    String? type,
    String? status,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Generate unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'TRX-$timestamp-$random';
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    try {
      final transactionId = transaction.transactionId.isEmpty
          ? _generateTransactionId()
          : transaction.transactionId;

      final transactionModel = TransactionModel(
        transactionId: transactionId,
        userId: transaction.userId,
        type: transaction.type,
        amount: transaction.amount,
        referenceId: transaction.referenceId,
        date: transaction.date,
        status: transaction.status,
        notes: transaction.notes,
      );

      await _dbRef.child('transactions').child(transactionId).set(transactionModel.toMap());
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    String? userId,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _dbRef.child('transactions').orderByChild('date');

      if (userId != null) {
        query = query.orderByChild('userId').equalTo(userId);
      }

      final snapshot = await query.get();
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<TransactionEntity> transactions = [];

      data.forEach((key, value) {
        try {
          final transactionMap = value as Map<dynamic, dynamic>;
          final transaction = TransactionModel.fromMap({
            ...transactionMap,
            'transactionId': key.toString(),
          }).toEntity();

          // Apply additional filters
          bool shouldInclude = true;

          if (type != null) {
            final transactionType = transaction.type.toString().split('.').last;
            if (transactionType != type) {
              shouldInclude = false;
            }
          }

          if (status != null) {
            final transactionStatus = transaction.status.toString().split('.').last;
            if (transactionStatus != status) {
              shouldInclude = false;
            }
          }

          if (startDate != null && transaction.date.isBefore(startDate)) {
            shouldInclude = false;
          }

          if (endDate != null && transaction.date.isAfter(endDate)) {
            shouldInclude = false;
          }

          if (shouldInclude) {
            transactions.add(transaction);
          }
        } catch (e) {
          print('Error parsing transaction $key: $e');
        }
      });

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return transactions;
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByUser(String userId) async {
    return await getTransactions(userId: userId);
  }

  @override
  Future<TransactionEntity?> getTransactionById(String transactionId) async {
    try {
      final snapshot = await _dbRef.child('transactions').child(transactionId).get();
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return TransactionModel.fromMap({
        ...data,
        'transactionId': transactionId,
      }).toEntity();
    } catch (e) {
      print('Error fetching transaction by ID: $e');
      return null;
    }
  }

  @override
  Future<void> updateTransactionStatus({
    required String transactionId,
    required String status,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        if (notes != null) 'notes': notes,
      };

      await _dbRef.child('transactions').child(transactionId).update(updateData);
    } catch (e) {
      print('Error updating transaction status: $e');
      rethrow;
    }
  }

  // =======================================================
  // 🔥 NEW: IMPLEMENTATION FOR BNPL DEBT LOGIC
  // =======================================================
  @override
  Future<TransactionEntity?> getLastPendingBnplTransaction({
    required String userId,
    String? type,
    String? status,
  }) async {
    try {
      // 1. Query by userId (only one orderByChild is allowed)
      // orderByChild('userId').equalTo(userId) ကို အသုံးပြုပြီး သက်ဆိုင်ရာ User ၏ transactions အားလုံးကို ဆွဲယူမည်
      final Query query = _dbRef
          .child('transactions')
          .orderByChild('userId')
          .equalTo(userId);

      final snapshot = await query.get();
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      TransactionEntity? lastPendingTrx;
      DateTime? latestDate;

      data.forEach((key, value) {
        try {
          final transactionMap = value as Map<dynamic, dynamic>;
          final transaction = TransactionModel.fromMap({
            ...transactionMap,
            'transactionId': key.toString(),
          }).toEntity();

          // 2. Client-side filtering for type (subscription) and status (pending)
          final transactionTypeStr = transaction.type.toString().split('.').last;
          final transactionStatusStr = transaction.status.toString().split('.').last;

          if (transactionTypeStr == type && transactionStatusStr == status) {
            // 3. Find the latest one
            if (latestDate == null || transaction.date.isAfter(latestDate!)) {
              latestDate = transaction.date;
              lastPendingTrx = transaction;
            }
          }
        } catch (e) {
          print('Error parsing BNPL transaction $key: $e');
        }
      });

      // 4. Return the latest pending BNPL transaction found
      return lastPendingTrx;

    } catch (e) {
      print('Error fetching last pending BNPL transaction: $e');
      return null;
    }
  }
}