// lib/domain/usecases/user/update_user_status_usecase.dart
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class UpdateUserStatusUseCase {
  final AuthRepository authRepository;

  UpdateUserStatusUseCase(this.authRepository);

  Future<void> call(String userId, UserStatus newStatus) async {
    // 1. Get user first
    final user = await authRepository.getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // 2. Update status
    final updatedUser = user.copyWith(status: newStatus);

    // 3. Save to repository
    await authRepository.updateUserDetails(updatedUser);
  }
}