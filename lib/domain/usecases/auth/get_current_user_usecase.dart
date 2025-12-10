// lib/domain/usecases/auth/get_current_user.dart
import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  // 🔥 Sync version ကနေ Async version ကို ပြောင်းပါ
  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}