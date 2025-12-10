// lib/domain/usecases/topup/get_user_top_up_usecase.dart
import '../../entities/top_up_entity.dart';
import '../../repositories/top_up_repository.dart';

class GetUserTopUpUseCase {
  final TopUpRepository repository;

  GetUserTopUpUseCase(this.repository);

  Future<List<TopUpEntity>> call(String userId) async {
    return await repository.getTopUpByUser(userId);
  }
}
