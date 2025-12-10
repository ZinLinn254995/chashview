// lib/domain/usecases/plan/create_plan_usecase.dart (Admin)
import '../../entities/plan_entity.dart';
import '../../repositories/plan_repository.dart';

class CreatePlanUseCase {
  final PlanRepository repository;

  CreatePlanUseCase(this.repository);

  Future<void> call(PlanEntity plan) async {
    return await repository.createPlan(plan);
  }
}