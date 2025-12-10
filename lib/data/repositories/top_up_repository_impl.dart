// lib/data/repositories/top_up_repository_impl.dart
import '../../domain/entities/top_up_entity.dart';
import '../../domain/repositories/top_up_repository.dart';
import '../datasources/top_up_remote_data_source.dart';

class TopUpRepositoryImpl implements TopUpRepository {
  final TopUpRemoteDataSource remoteDataSource;

  TopUpRepositoryImpl(this.remoteDataSource);

  @override
  Future<TopUpEntity> generateTopUpCode({
    required String planId,
    required String adminId,
    required String expireAt,
  }) async {
    return await remoteDataSource.generateTopUpCode(
      planId: planId,
      adminId: adminId,
      expireAt: expireAt,
    );
  }

  @override
  Future<List<TopUpEntity>> getTopUpCodes({
    String? status,
    String? planId,
  }) async {
    return await remoteDataSource.getTopUpCodes(
      status: status,
      planId: planId,
    );
  }

  @override
  Future<TopUpEntity?> getTopUpByCode(String code) async {
    return await remoteDataSource.getTopUpByCode(code);
  }

  @override
  Future<TopUpEntity> validateTopUpCode(String code) async {
    return await remoteDataSource.validateTopUpCode(code);
  }

  @override
  Future<void> redeemTopUpCode({
    required String code,
    required String userId,
  }) async {
    await remoteDataSource.redeemTopUpCode(
      code: code,
      userId: userId,
    );
  }

  @override
  Future<void> updateTopUp(TopUpEntity topUp) async {
    await remoteDataSource.updateTopUp(topUp);
  }

  @override
  Future<void> updateTopUpStatus({
    required String code,
    required String status,
  }) async {
    await remoteDataSource.updateTopUpStatus(
      code: code,
      status: status,
    );
  }

  @override
  Future<List<TopUpEntity>> getTopUpByUser(String userId) async {
    return await remoteDataSource.getTopUpByUser(userId);
  }
}