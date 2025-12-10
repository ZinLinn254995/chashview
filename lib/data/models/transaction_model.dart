// lib/data/models/transaction_model.dart
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.transactionId,
    required super.userId,
    required super.type,
    required super.amount,
    required super.referenceId,
    required super.date,
    required super.status,
    super.notes,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] as String,
      userId: map['userId'] as String,
      type: _parseTransactionType(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      referenceId: map['referenceId'] as String,
      date: _parseDateTime(map['date']),
      status: _parseTransactionStatus(map['status'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'type': _typeToString(type),
      'amount': amount,
      'referenceId': referenceId,
      'date': _dateToString(date),
      'status': _statusToString(status),
      if (notes != null) 'notes': notes,
    };
  }

  TransactionEntity toEntity() => this;

  // Helper methods
  static TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'topupcode':
        return TransactionType.topUpCode;
      case 'subscription':
        return TransactionType.subscription;
      case 'refund':
        return TransactionType.refund;
      default:
        throw FormatException('Invalid TransactionType: $type');
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return TransactionStatus.completed;
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        throw FormatException('Invalid TransactionStatus: $status');
    }
  }

  static String _typeToString(TransactionType type) {
    return type.toString().split('.').last;
  }

  static String _statusToString(TransactionStatus status) {
    return status.toString().split('.').last;
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.parse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    throw FormatException('Cannot parse date: $date');
  }

  static String _dateToString(DateTime date) {
    return date.toIso8601String();
  }
}