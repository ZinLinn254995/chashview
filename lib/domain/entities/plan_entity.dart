// lib/domain/entities/plan_entity.dart

// =======================================================
// 1. SubscriptionType Enhanced Enum (Plan Rules)
// =======================================================

enum SubscriptionType {
  // 💡 durationDays နှင့် category ကို အစဉ်လိုက် ထည့်သွင်း (Positional)
  //      Duration, Category
  monthly(30, 'bnpl_standard'),
  halfYearly(180, 'upgrade_prorated'),
  yearly(365, 'upgrade_prorated'),
  lifetime(99999, 'upgrade_waive');

  final int durationDays;
  final String category; // Business Logic စစ်ဆေးရန် သော့ချက်

  // ✨ Constructor ကို Positional အဖြစ် ပြောင်းလိုက်ပါ
  const SubscriptionType(this.durationDays, this.category);

  // Helper method: Database key (String) မှ Enum ကို ရှာဖွေနိုင်ရန်
  static SubscriptionType? fromKey(String key) {
    try {
      return SubscriptionType.values.firstWhere(
            (e) => e.name == key,
      );
    } catch (e) {
      return null;
    }
  }
}

// =======================================================
// 2. PlanEntity (Data Structure using Enum)
// =======================================================

class PlanEntity {
  final String planId;
  final String name;
  final double price; // ငွေကြေး/BNPL တွက်ချက်မှုအတွက် မဖြစ်မနေလိုအပ်သော field

  // ✨ DurationDays နှင့် Category နှစ်ခုလုံးကို ကိုယ်စားပြုသော Enum
  final SubscriptionType type;

  PlanEntity({
    required this.planId,
    required this.name,
    required this.price,
    required this.type,
  });

  // Getter များဖြင့် Business Logic တွင် အသုံးပြုရန် လွယ်ကူစေခြင်း

  /// Subscription သက်တမ်း (ရက်အရေအတွက်) ကို ပြန်ပေးသည်။
  int get durationDays => type.durationDays;

  /// ငွေပေးချေမှု အမျိုးအစား (e.g., 'bnpl_standard', 'upgrade_waive') ကို ပြန်ပေးသည်။
  String get category => type.category;


  // -------------------------
  // 🔥 copyWith() method
  // -------------------------
  PlanEntity copyWith({
    String? planId,
    String? name,
    double? price,
    SubscriptionType? type, // Enum Type ကို အသုံးပြု
  }) {
    return PlanEntity(
      planId: planId ?? this.planId,
      name: name ?? this.name,
      price: price ?? this.price,
      type: type ?? this.type,
    );
  }
}