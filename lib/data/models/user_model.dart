// lib/data/models/user_model.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
// Note: UserEntity မှာပဲ UserStatus နဲ့ UserRole enum တွေ ပါဝင်နေတယ်လို့ ယူဆပါတယ်။

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.photoUrl,
    required super.displayId,
    required super.createdAt,
    required super.trialStartDate,
    required super.trialEndDate,
    required super.isTrialUsed,
    super.currentPlanId,
    super.subscriptionEnd,
    required super.status,
    required super.role,
    required super.hasActiveBnplDebt,
  });

  // ----------------------------------------------------
  // 📌 Factory: Firebase Auth → First time user creation
  // ----------------------------------------------------
  /// Firebase User data မှ ပထမဆုံးအကြိမ် User Model အဖြစ် ဖန်တီးသည်။
  factory UserModel.fromFirebaseUser(User user) {
    final now = DateTime.now();
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
      displayId: "USER-${user.uid.substring(0, 6)}",
      createdAt: now,
      trialStartDate: now,
      trialEndDate: now.add(const Duration(days: 7)),
      isTrialUsed: false,
      status: UserStatus.free, // Default status
      role: UserRole.user, // 🔥 Default role
      currentPlanId: null,
      subscriptionEnd: null,
      hasActiveBnplDebt: false,
    );
  }

  // ----------------------------------------------------
  // 🔥 Firestore / Realtime DB -> Model
  // ----------------------------------------------------
  /// Map (Firestore/DB) မှ UserModel အဖြစ် ပြောင်းလဲသည်။
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Helper function to safely convert enum string to enum value
    UserStatus statusFromString(String statusName) {
      try {
        return UserStatus.values.byName(statusName);
      } catch (e) {
        return UserStatus.free; // Fallback
      }
    }

    UserRole roleFromString(String roleName) {
      try {
        return UserRole.values.byName(roleName);
      } catch (e) {
        return UserRole.user; // Fallback
      }
    }

    // Convert timestamp/string to DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      // If your DB uses Firebase Timestamp/Unix time, conversion logic goes here
      return null;
    }

    return UserModel(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String,
      displayId: map['displayId'] as String,
      createdAt: parseDateTime(map['createdAt'])!,
      trialStartDate: parseDateTime(map['trialStartDate'])!,
      trialEndDate: parseDateTime(map['trialEndDate'])!,
      isTrialUsed: map['isTrialUsed'] as bool,
      currentPlanId: map['currentPlanId'] as String?,
      subscriptionEnd: parseDateTime(map['subscriptionEnd']),
      status: statusFromString(map['status'] as String),
      role: roleFromString(map['role'] as String), // 🔥 Role ကို map မှ ဆွဲထုတ်
      hasActiveBnplDebt: map['hasActiveBnplDebt'] as bool,
    );
  }

  // ----------------------------------------------------
  // 🔥 ToMap (save to Firestore)
  // ----------------------------------------------------
  /// UserModel မှ Map အဖြစ် ပြောင်းလဲသည်။
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'displayId': displayId,
      'createdAt': createdAt.toIso8601String(),
      'trialStartDate': trialStartDate.toIso8601String(),
      'trialEndDate': trialEndDate.toIso8601String(),
      'isTrialUsed': isTrialUsed,
      'currentPlanId': currentPlanId,
      'subscriptionEnd': subscriptionEnd?.toIso8601String(),
      'status': status.name, // Enum ကို String အဖြစ် သိမ်းဆည်း
      'role': role.name, // 🔥 Role ကို String အဖြစ် သိမ်းဆည်း
      'hasActiveBnplDebt' : hasActiveBnplDebt,
    };
  }

  UserEntity toEntity() => this;
}