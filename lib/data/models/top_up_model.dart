// lib/data/models/top_up_model.dart

import '../../domain/entities/top_up_entity.dart';

class TopUpModel extends TopUpEntity {
  TopUpModel({
    required super.code,
    required super.planId,
    required super.generatedByAdmin,
    required super.expireAt,
    super.usedByUserId,
    super.usedAt,
    required super.status, // TopUpStatus ကို အသုံးပြု
  });

  // ----------------------------------------------------
  // 🔥 Firestore / Realtime DB -> Model (From Map)
  // ----------------------------------------------------
  factory TopUpModel.fromMap(Map<String, dynamic> map) {
    // 💡 Helper function ဖြင့် String မှ TopUpStatus သို့ ပြောင်းလဲ
    TopUpStatus getStatus(String status) {
      return TopUpStatus.values.firstWhere(
            (e) => e.name == status,
        orElse: () => TopUpStatus.disabled, // မမှန်ကန်သော Status ဖြစ်ပါက disabled ပြန်ပေး
      );
    }

    return TopUpModel(
      code: map['code'] as String,
      planId: map['planId'] as String,
      generatedByAdmin: map['generatedByAdmin'] as String,
      expireAt: map['expireAt'] as String,
      usedByUserId: map['usedByUserId'] as String?,
      usedAt: map['usedAt'] as String?,
      status: getStatus(map['status'] as String), // 💡 String ကို Enum အဖြစ် ပြောင်းလဲ
    );
  }

  // ----------------------------------------------------
  // 🔥 ToMap (save to Firestore)
  // ----------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'planId': planId,
      'generatedByAdmin': generatedByAdmin,
      'expireAt': expireAt,
      'usedByUserId': usedByUserId,
      'usedAt': usedAt,
      'status': status.name, // 💡 Enum ကို String အဖြစ် ပြန်ပြောင်း (e.g., TopUpStatus.active -> "active")
    };
  }

  // ➡️ To Entity (No Change, as Model extends Entity)
  TopUpEntity toEntity() => this;
}