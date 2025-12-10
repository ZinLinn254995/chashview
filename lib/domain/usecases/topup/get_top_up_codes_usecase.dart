// lib/domain/usecases/topup/get_top_up_codes_usecase.dart (Admin)
import '../../entities/top_up_entity.dart';
import '../../repositories/top_up_repository.dart';

class GetTopUpCodesUseCase {
  final TopUpRepository repository;

  GetTopUpCodesUseCase(this.repository);

  Future<List<TopUpEntity>> call({
    String? status,
    String? planId,
  }) async {
    return await repository.getTopUpCodes(
      status: status,
      planId: planId,
    );
  }
}