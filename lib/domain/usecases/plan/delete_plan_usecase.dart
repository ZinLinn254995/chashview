// lib/domain/usecases/plan/delete_plan_usecase.dart (Admin)
import '../../repositories/plan_repository.dart';

class DeletePlanUseCase {
  final PlanRepository repository;

  DeletePlanUseCase(this.repository);

  Future<void> call(String planId) async {
    return await repository.deletePlan(planId);
  }
}