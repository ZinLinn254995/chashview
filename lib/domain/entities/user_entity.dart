// lib/domain/entities/user_entity.dart

enum UserStatus { // Subscription အခြေအနေ
  free, // အခမဲ့အဆင့်
  pro, // အခပေးအဆင့်
  expired, // အခပေးသက်တမ်းကုန်ဆုံး
  suspended, // စနစ်မှ ရပ်ဆိုင်းထား
}

enum UserRole { // လုပ်ပိုင်ခွင့်
  user,
  admin,
  moderator,
}

class UserEntity {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String displayId;
  final DateTime createdAt;
  final DateTime trialStartDate;
  final DateTime trialEndDate;
  final bool isTrialUsed;
  final String? currentPlanId;
  final DateTime? subscriptionEnd;
  final UserStatus status;
  final UserRole role;
  final bool hasActiveBnplDebt;


  UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.displayId,
    required this.createdAt,
    required this.trialStartDate,
    required this.trialEndDate,
    required this.isTrialUsed,
    this.currentPlanId,
    this.subscriptionEnd,
    required this.status,
    required this.role,
    required this.hasActiveBnplDebt,
  });

  // -------------------------
  // 🔥 copyWith() method here
  // -------------------------
  UserEntity copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? displayId,
    DateTime? createdAt,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    bool? isTrialUsed,
    String? currentPlanId,
    DateTime? subscriptionEnd,
    UserStatus? status,
    UserRole? role, // copyWith တွင် ထည့်သွင်း
    bool? hasActiveBnplDebt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      displayId: displayId ?? this.displayId,
      createdAt: createdAt ?? this.createdAt,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      isTrialUsed: isTrialUsed ?? this.isTrialUsed,
      currentPlanId: currentPlanId ?? this.currentPlanId,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      status: status ?? this.status,
      role: role ?? this.role,
      hasActiveBnplDebt: hasActiveBnplDebt ?? this.hasActiveBnplDebt,
    );
  }
}