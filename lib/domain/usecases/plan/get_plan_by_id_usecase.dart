// lib/domain/usecases/plan/get_plan_by_id_usecase.dart
import '../../entities/plan_entity.dart';
import '../../repositories/plan_repository.dart';

class GetPlanByIdUseCase {
  final PlanRepository repository;

  GetPlanByIdUseCase(this.repository);

  Future<PlanEntity?> call(String planId) async {
    return await repository.getPlanById(planId);
  }
}