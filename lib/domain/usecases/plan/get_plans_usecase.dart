// lib/domain/usecases/plan/get_plans_usecase.dart
import '../../entities/plan_entity.dart';
import '../../repositories/plan_repository.dart';

class GetPlansUseCase {
  final PlanRepository repository;

  GetPlansUseCase(this.repository);

  Future<List<PlanEntity>> call() async {
    return await repository.getPlans();
  }
}