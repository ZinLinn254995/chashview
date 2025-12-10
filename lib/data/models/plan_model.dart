// lib/data/models/plan_model.dart

import '../../domain/entities/plan_entity.dart';


class PlanModel extends PlanEntity {
  PlanModel({
    required super.planId,
    required super.name,
    required super.price,
    required super.type, // 💡 SubscriptionType enum
  });

  // ----------------------------------------------------
  // 🔥 Firestore / Realtime DB -> Model (From Map)
  // ----------------------------------------------------
  /// Map (Firestore/DB) မှ PlanModel အဖြစ် ပြောင်းလဲသည်။
  factory PlanModel.fromMap(Map<String, dynamic> map) {
    final String typeKey = map['type'] as String; // DB မှ String key ကို ယူ

    // Helper method သုံးပြီး String မှ SubscriptionType Enum သို့ ပြောင်းလဲ
    final SubscriptionType? subscriptionType = SubscriptionType.fromKey(typeKey);

    if (subscriptionType == null) {
      // DB ထဲမှာ မသိတဲ့ Plan Type ဝင်နေရင် Error ပစ်ရန်
      throw FormatException('Invalid subscription type key: $typeKey found in DB.');
    }

    return PlanModel(
      planId: map['planId'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(), // num မှ double သို့ ပြောင်းလဲခြင်း
      type: subscriptionType, // 💡 Enum ကို ပေးပို့ခြင်း
    );
  }

  // ----------------------------------------------------
  // 🔥 ToMap (save to Firestore)
  // ----------------------------------------------------
  /// PlanModel မှ Map အဖြစ် ပြောင်းလဲသည်။
  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'name': name,
      'price': price,
      'type': type.name, // 💡 Enum value (e.g., 'monthly') ကို String အဖြစ် သိမ်းဆည်း
    };
  }

  PlanEntity toEntity() => this;
}