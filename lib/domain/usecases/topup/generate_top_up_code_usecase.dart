// lib/domain/usecases/topup/generate_top_up_code_usecase.dart (Admin)
import '../../entities/top_up_entity.dart';
import '../../repositories/top_up_repository.dart';

class GenerateTopUpCodeUseCase {
  final TopUpRepository repository;

  GenerateTopUpCodeUseCase(this.repository);

  Future<TopUpEntity> call({
    required String planId,
    required String adminId,
    required String expireAt,
  }) async {
    return await repository.generateTopUpCode(
      planId: planId,
      adminId: adminId,
      expireAt: expireAt,
    );
  }
}