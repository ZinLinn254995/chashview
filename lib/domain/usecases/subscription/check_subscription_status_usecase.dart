// lib/domain/usecases/subscription/check_subscription_status_usecase.dart
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class CheckSubscriptionStatusUseCase {
  final AuthRepository authRepository;

  CheckSubscriptionStatusUseCase({required this.authRepository});

  Future<UserEntity> call() async {
    // Get current user from auth repository
    final user = await authRepository.getCurrentUser();

    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if subscription is expired
    if (user.subscriptionEnd != null &&
        user.subscriptionEnd!.isBefore(DateTime.now())) {
      // Update user status to expired
      final updatedUser = user.copyWith(
        status: UserStatus.expired,
      );

      // Update user in auth repository
      await authRepository.updateUserDetails(updatedUser);

      return updatedUser;
    }

    return user;
  }
}