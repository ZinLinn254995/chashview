// lib/domain/usecases/topup/update_top_up_status_usecase.dart (Admin)
import '../../repositories/top_up_repository.dart';

class UpdateTopUpStatusUseCase {
  final TopUpRepository repository;

  UpdateTopUpStatusUseCase(this.repository);

  Future<void> call({
    required String code,
    required String status,
  }) async {
    return await repository.updateTopUpStatus(
      code: code,
      status: status,
    );
  }
}