// lib/domain/usecases/topup/redeem_top_up_code_usecase.dart
import '../../entities/top_up_entity.dart';
import '../../entities/user_entity.dart';
import '../../repositories/top_up_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/plan_repository.dart';

class RedeemTopUpCodeUseCase {
  final TopUpRepository topUpRepository;
  final AuthRepository authRepository;
  final PlanRepository planRepository;

  RedeemTopUpCodeUseCase({
    required this.topUpRepository,
    required this.authRepository,
    required this.planRepository,
  });

  Future<UserEntity> call({
    required String code,
    // 🔥 REMOVE userId parameter
  }) async {
    // 1. Get current user
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // 2. Get and validate top-up code
    final topUp = await topUpRepository.getTopUpByCode(code);

    if (topUp == null) {
      throw Exception('Invalid top-up code');
    }

    if (topUp.status != TopUpStatus.active) {
      throw Exception('Top-up code is not active');
    }

    if (topUp.usedByUserId != null) {
      throw Exception('Top-up code already used');
    }

    // 3. Get plan details
    final plan = await planRepository.getPlanById(topUp.planId);
    if (plan == null) {
      throw Exception('Associated plan not found');
    }

    // 4. Calculate new subscription end date
    DateTime newSubscriptionEnd;
    final now = DateTime.now();

    if (currentUser.subscriptionEnd != null &&
        currentUser.subscriptionEnd!.isAfter(now)) {
      // Extend from current end date
      newSubscriptionEnd = currentUser.subscriptionEnd!.add(
        Duration(days: plan.durationDays),
      );
    } else {
      // Start from now
      newSubscriptionEnd = now.add(
        Duration(days: plan.durationDays),
      );
    }

    // 5. Update user
    final updatedUser = currentUser.copyWith(
      currentPlanId: plan.planId,
      subscriptionEnd: newSubscriptionEnd,
      status: UserStatus.pro,
    );

    await authRepository.updateUserDetails(updatedUser);

    // 6. Mark top-up as used
    await topUpRepository.updateTopUp(
      topUp.copyWith(
        usedByUserId: currentUser.uid, // 🔥 Use current user's ID
        usedAt: DateTime.now().toIso8601String(),
        status: TopUpStatus.used,
      ),
    );

    return updatedUser;
  }
}