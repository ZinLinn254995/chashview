// lib/data/repositories/plan_repository_impl.dart
import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/plan_remote_data_source.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanRemoteDataSource remoteDataSource;

  PlanRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PlanEntity>> getPlans() async {
    return await remoteDataSource.getPlans();
  }

  @override
  Future<PlanEntity?> getPlanById(String planId) async {
    return await remoteDataSource.getPlanById(planId);
  }

  @override
  Future<void> createPlan(PlanEntity plan) async {
    await remoteDataSource.createPlan(plan);
  }

  @override
  Future<void> updatePlan(PlanEntity plan) async {
    await remoteDataSource.updatePlan(plan);
  }

  @override
  Future<void> deletePlan(String planId) async {
    await remoteDataSource.deletePlan(planId);
  }
}