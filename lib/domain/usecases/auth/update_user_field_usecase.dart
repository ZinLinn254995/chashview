// lib/domain/usecases/user/update_user_field.dart
import '../../repositories/auth_repository.dart';

class UpdateUserFieldUseCase {
  final AuthRepository repository;

  UpdateUserFieldUseCase(this.repository);

  Future<void> call(String uid, String field, dynamic value) async {
    await repository.updateUserField(uid, field, value);
  }
}