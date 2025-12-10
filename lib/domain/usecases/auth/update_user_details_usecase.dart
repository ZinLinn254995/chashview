// lib/domain/usecases/user/update_user_details.dart
import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class UpdateUserDetailsUseCase {
  final AuthRepository repository;

  UpdateUserDetailsUseCase(this.repository);

  Future<void> call(UserEntity user) async {
    await repository.updateUserDetails(user);
  }
}
