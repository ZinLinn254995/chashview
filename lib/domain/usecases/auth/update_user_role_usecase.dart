// lib/domain/usecases/user/update_user_role_usecase.dart
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class UpdateUserRoleUseCase {
  final AuthRepository authRepository;

  UpdateUserRoleUseCase(this.authRepository);

  Future<void> call(String userId, UserRole newRole) async {
    // 1. Get user first
    final user = await authRepository.getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // 2. Update role
    final updatedUser = user.copyWith(role: newRole);

    // 3. Save to repository
    await authRepository.updateUserDetails(updatedUser);
  }
}