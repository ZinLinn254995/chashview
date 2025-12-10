import '../../entities/top_up_entity.dart';
import '../../entities/transaction_entity.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/top_up_repository.dart';
import '../../repositories/plan_repository.dart';
import '../../repositories/transaction_repository.dart';

class ApplyTopUpToSubscriptionUseCase {
  final TopUpRepository topUpRepository;
  final AuthRepository authRepository;
  final PlanRepository planRepository;
  final TransactionRepository transactionRepository;

  ApplyTopUpToSubscriptionUseCase({
    required this.topUpRepository,
    required this.authRepository,
    required this.planRepository,
    required this.transactionRepository,
  });

  Future<UserEntity> call({
    required String code,
  }) async {
    // 1. Get current user
    final currentUser = await authRepository.getCurrentUser();
    if (currentUser == null) throw Exception('User not authenticated');

    // 2. Validate Top-Up Code
    final topUp = await topUpRepository.getTopUpByCode(code);
    if (topUp == null) throw Exception('Invalid top-up code');
    if (topUp.status != TopUpStatus.active) throw Exception('Code inactive');
    if (topUp.usedByUserId != null) throw Exception('Code already used');

    // 3. Get Plan Details
    final newPlan = await planRepository.getPlanById(topUp.planId);
    if (newPlan == null) throw Exception('Plan not found');

    DateTime newSubscriptionEnd;
    final now = DateTime.now();
    bool isDebtSettled = false; // Flag to track status

    // =========================================================================
    // 🔥 ADVANCED LOGIC: BNPL DEBT HANDLING
    // =========================================================================
    if (currentUser.hasActiveBnplDebt) {

      // Step A: Find the BNPL Transaction to calculate "Used Days"
      // (User ၏ နောက်ဆုံး Pending ဖြစ်နေသော Transaction ကို ရှာပါ)
      final lastBnplTrx = await transactionRepository.getLastPendingBnplTransaction(currentUser.uid);

      if (lastBnplTrx == null) {
        // Data Error ဖြစ်နေလျှင် Default အနေဖြင့် ရက်မနှုတ်ဘဲ ဒီနေ့မှစ၍ အသစ်စပါ
        newSubscriptionEnd = now.add(Duration(days: newPlan.durationDays));
      } else {
        // Step B: Calculate Used Days (အသုံးပြုပြီးသား ရက်အရေအတွက်)
        final bnplStartDate = lastBnplTrx.date;
        final int daysUsed = now.difference(bnplStartDate).inDays;

        // Step C: Check if it is Upgrade or Settlement
        // (Plan ID မတူရင် Upgrade ဟု ယူဆသည်)
        if (newPlan.planId != currentUser.currentPlanId) {

          // 🔥 UPGRADE SCENARIO (Deduct Used Days)
          // ဥပမာ: Yearly (365) - Used (10) = 355 Days from NOW

          int adjustedDuration = newPlan.durationDays - daysUsed;

          // အကယ်၍ အသုံးပြုရက်က ဝယ်မည့် Plan ထက် များနေရင် (မဖြစ်နိုင်သလောက်ပေမယ့်) 0 မဖြစ်အောင်ကာကွယ်
          if (adjustedDuration < 0) adjustedDuration = 0;

          newSubscriptionEnd = now.add(Duration(days: adjustedDuration));

          print('Advanced Logic: Deducted $daysUsed days from new plan.');

        } else {
          // 🔥 SETTLEMENT SCENARIO (Same Plan)
          // Monthly ကြွေးကို Monthly Code နဲ့ ပြန်ဆပ်ခြင်း (ရက်တိုးစရာမလို၊ အကြွေးကျေရုံသာ)
          // လက်ရှိ Subscription End Date ကို မပြောင်းလဲပါ
          newSubscriptionEnd = currentUser.subscriptionEnd ?? now;
        }
      }

      isDebtSettled = true; // အကြွေးရှင်းပြီးကြောင်း မှတ်သား

      // Update the OLD Pending Transaction to Completed (Optional but recommended)
      if (lastBnplTrx != null) {
        await transactionRepository.updateTransactionStatus(
          transactionId: lastBnplTrx.transactionId,
          status: TransactionStatus.completed, // Or 'cancelled' based on preference
          notes: 'Settled via Upgrade/TopUp: $code',
        );
      }

    }
    // =========================================================================
    // 🔥 NORMAL SCENARIO (No Debt)
    // =========================================================================
    else {
      // Standard Stacking Logic
      if (currentUser.subscriptionEnd != null && currentUser.subscriptionEnd!.isAfter(now)) {
        newSubscriptionEnd = currentUser.subscriptionEnd!.add(Duration(days: newPlan.durationDays));
      } else {
        newSubscriptionEnd = now.add(Duration(days: newPlan.durationDays));
      }
    }

    // 4. Update User Entity
    final updatedUser = currentUser.copyWith(
      currentPlanId: newPlan.planId,
      subscriptionEnd: newSubscriptionEnd,
      status: UserStatus.pro,
      hasActiveBnplDebt: isDebtSettled ? false : currentUser.hasActiveBnplDebt, // 🔥 Clear debt if settled
      isTrialUsed: true,
    );

    await authRepository.updateUserDetails(updatedUser);

    // 5. Mark Top-Up as Used
    await topUpRepository.updateTopUp(
      topUp.copyWith(
        usedByUserId: currentUser.uid,
        usedAt: now.toIso8601String(),
        status: TopUpStatus.used,
      ),
    );

    // 6. Create Transaction Record (New Payment)
    try {
      final transaction = TransactionEntity(
        transactionId: '',
        userId: currentUser.uid,
        type: TransactionType.topUpCode,
        amount: newPlan.price.toDouble(),
        referenceId: code,
        date: now,
        status: TransactionStatus.completed,
        notes: isDebtSettled
            ? 'Debt Settled & Subscribed to ${newPlan.name}'
            : 'Subscribed to ${newPlan.name}',
      );
      await transactionRepository.createTransaction(transaction);
    } catch (e) {
      print('Warning: Failed to create transaction: $e');
    }

    return updatedUser;
  }
}