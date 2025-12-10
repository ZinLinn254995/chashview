// lib/domain/entities/top_up_entity.dart

enum TopUpStatus {
  active,
  used,
  expired,
  disabled,
}

class TopUpEntity {
  final String code;
  final String planId;
  final String generatedByAdmin;
  final String expireAt;
  final String? usedByUserId;
  final String? usedAt;
  final TopUpStatus status; // ✨ String အစား TopUpStatus ဖြင့် အစားထိုး

  TopUpEntity({
    required this.code,
    required this.planId,
    required this.generatedByAdmin,
    required this.expireAt,
    this.usedByUserId,
    this.usedAt,
    required this.status,
  });

  // -------------------------
  // 🔥 copyWith() method
  // -------------------------
  TopUpEntity copyWith({
    String? code,
    String? planId,
    String? generatedByAdmin,
    String? expireAt,
    String? usedByUserId,
    String? usedAt,
    TopUpStatus? status, // ✨ TopUpStatus ဖြင့် ပြောင်းလဲ
  }) {
    return TopUpEntity(
      code: code ?? this.code,
      planId: planId ?? this.planId,
      generatedByAdmin: generatedByAdmin ?? this.generatedByAdmin,
      expireAt: expireAt ?? this.expireAt,
      usedByUserId: usedByUserId ?? this.usedByUserId,
      usedAt: usedAt ?? this.usedAt,
      status: status ?? this.status,
    );
  }
}