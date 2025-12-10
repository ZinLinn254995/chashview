import 'package:flutter/foundation.dart';

import '../../entities/transaction_entity.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/plan_repository.dart';
import '../../repositories/transaction_repository.dart';

class ActivateBnplSubscriptionUseCase {
  final AuthRepository authRepository;
  final PlanRepository planRepository;
  final TransactionRepository transactionRepository;

  ActivateBnplSubscriptionUseCase({
    required this.authRepository,
    required this.planRepository,
    required this.transactionRepository,
  });

  // 💡 Note: bnplTransactionId သည် 3rd party (ဥပမာ: Payment Gateway) မှ ရရှိသော ID ဖြစ်သည်ဟု ယူဆပါသည်။
  Future<UserEntity> call({
    required String planId,
  }) async {
    // 1. Get current user from auth repository
    final currentUser = await authRepository.getCurrentUser();

    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // 2. Get and validate plan details
    final plan = await planRepository.getPlanById(planId);
    if (plan == null) {
      throw Exception('Plan not found');
    }

    // Define allowed statuses for BNPL activation
    const allowedStatuses = {UserStatus.free, UserStatus.expired};

    // 🔥 Business Rule Validation (Monthly Plan + Free User)

    // a. Plan သည် BNPL Category (monthly) ဟုတ်မဟုတ် စစ်ဆေးခြင်း
    if (plan.category != 'bnpl_standard') {
      throw Exception('This plan cannot be activated via BNPL.');
    }

    // b. User Status Check: 'pro' သို့မဟုတ် 'suspended' ကို တားမြစ်ခြင်း
    if (!allowedStatuses.contains(currentUser.status)) {
      throw Exception(
          'BNPL activation is only available for free or expired users.'
      );
    }

    // c. User တွင် BNPL ကြွေးကျန် ရှိနေခြင်း ရှိမရှိ စစ်ဆေးခြင်း (Duplicate prevention)
    if (currentUser.hasActiveBnplDebt) {
      throw Exception('You already have an active BNPL debt. Please settle the previous plan first.');
    }

    // 3. Calculate new subscription end date (Start from now)
    final now = DateTime.now();
    final newSubscriptionEnd = now.add(
      Duration(days: plan.durationDays), // Monthly = 30 days
    );

    // 4. Update user details (Activate Subscription & Mark Debt)
    final updatedUser = currentUser.copyWith(
      currentPlanId: plan.planId,
      subscriptionEnd: newSubscriptionEnd,
      status: UserStatus.pro, // Pro status ပေးလိုက်သည်
      hasActiveBnplDebt: true, // 🔥 BNPL ကြွေးကျန် ရှိကြောင်း မှတ်သားလိုက်သည်
      isTrialUsed: true, // Trial ကာလကို ကျော်လွန်သွားသောကြောင့်
    );

    await authRepository.updateUserDetails(updatedUser);

    // 🔥 5. Create Transaction Record (Status: PENDING)
    try {
      final uniqueReferenceId = 'BNPL_REF_${now.microsecondsSinceEpoch}';
      final newTransaction = TransactionEntity(
        transactionId: '', // DataSource will generate ID
        userId: currentUser.uid,
        type: TransactionType.subscription, // ပုံမှန် subscription ဝယ်ယူမှုအဖြစ် သတ်မှတ်
        amount: plan.price.toDouble(),
        referenceId: uniqueReferenceId, // BNPL Service မှ ရရှိသော ID
        date: now,
        status: TransactionStatus.pending, // 💡 ငွေပေးချေမှု မပြီးသေး၍ PENDING
        notes: 'BNPL activation of ${plan.name}. Payment expected via Top-Up Code.',
      );

      await transactionRepository.createTransaction(newTransaction);
    } catch (e) {
      // Transaction Record မှတ်တမ်းတင်ရန် ပျက်ကွက်ပါက၊ User ၏ Subscription ကို Rollback မလုပ်ဘဲ Warning သာ ပြသင့်သည်
      if (kDebugMode) {
        print('Warning: Failed to create BNPL transaction record: $e');
      }
    }

    return updatedUser;
  }
}