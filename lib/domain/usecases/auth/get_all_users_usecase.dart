// lib/domain/usecases/user/get_all_users_usecase.dart
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetAllUsersUseCase {
  final AuthRepository authRepository;

  GetAllUsersUseCase(this.authRepository);

  Future<List<UserEntity>> call() async {
    // ဒီ method ကို AuthRepository မှာ ထည့်ရန်လိုအပ်ပါတယ်
    return await authRepository.getAllUsers();
  }
}