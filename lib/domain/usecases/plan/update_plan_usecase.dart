// lib/domain/usecases/plan/update_plan_usecase.dart (Admin)
import '../../entities/plan_entity.dart';
import '../../repositories/plan_repository.dart';

class UpdatePlanUseCase {
  final PlanRepository repository;

  UpdatePlanUseCase(this.repository);

  Future<void> call(PlanEntity plan) async {
    return await repository.updatePlan(plan);
  }
}