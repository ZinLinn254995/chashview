// lib/domain/entities/transaction_entity.dart

enum TransactionType {
  topUpCode, // Top-up code ဖြင့် အသုံးပြုခြင်း (Redeem)
  subscription, // ပုံမှန် ငွေပေးချေမှု (Credit Card, etc.)
  refund, // ငွေပြန်အမ်းခြင်း
}

enum TransactionStatus {
  completed,
  pending,
  failed,
  cancelled,
}

class TransactionEntity {
  final String transactionId;
  final String userId; // လုပ်ဆောင်ခဲ့သော User ID
  final TransactionType type; // ငွေပေးချေမှု အမျိုးအစား
  final double amount; // ပေးချေသော ပမာဏ (Top-up အတွက် 0 ဖြစ်နိုင်)
  final String referenceId; // TopUp Code ID, Stripe ID, Invoice ID စသည်
  final DateTime date; // လုပ်ဆောင်ခဲ့သည့် နေ့ရက်/အချိန်
  final TransactionStatus status; // လက်ရှိ အခြေအနေ
  final String? notes; // အခြား မှတ်စုများ

  TransactionEntity({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.referenceId,
    required this.date,
    required this.status,
    this.notes,
  });

  // -------------------------
  // 🔥 copyWith() method
  // -------------------------
  TransactionEntity copyWith({
    String? transactionId,
    String? userId,
    TransactionType? type,
    double? amount,
    String? referenceId,
    DateTime? date,
    TransactionStatus? status,
    String? notes,
  }) {
    return TransactionEntity(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      referenceId: referenceId ?? this.referenceId,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}