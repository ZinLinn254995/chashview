// lib/domain/repositories/plan_repository.dart
import '../entities/plan_entity.dart';

abstract class PlanRepository {
  Future<List<PlanEntity>> getPlans();
  Future<PlanEntity?> getPlanById(String planId);
  Future<void> createPlan(PlanEntity plan);
  Future<void> updatePlan(PlanEntity plan);
  Future<void> deletePlan(String planId);
}
