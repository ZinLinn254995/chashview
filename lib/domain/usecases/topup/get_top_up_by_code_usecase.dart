// lib/domain/usecases/topup/get_top_up_by_code_usecase.dart
import '../../entities/top_up_entity.dart';
import '../../repositories/top_up_repository.dart';

class GetTopUpByCodeUseCase {
  final TopUpRepository repository;

  GetTopUpByCodeUseCase(this.repository);

  Future<TopUpEntity?> call(String code) async {
    return await repository.getTopUpByCode(code);
  }
}