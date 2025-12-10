// lib/domain/repositories/top_up_repository.dart
import '../entities/top_up_entity.dart';

abstract class TopUpRepository {
  Future<TopUpEntity> generateTopUpCode({
    required String planId,
    required String adminId,
    required String expireAt,
  });
  Future<List<TopUpEntity>> getTopUpCodes({
    String? status,
    String? planId,
  });
  Future<TopUpEntity?> getTopUpByCode(String code);
  Future<TopUpEntity> validateTopUpCode(String code);
  Future<void> redeemTopUpCode({
    required String code,
    required String userId,
  });
  Future<void> updateTopUp(TopUpEntity topUp);
  Future<void> updateTopUpStatus({
    required String code,
    required String status,
  });
  Future<List<TopUpEntity>> getTopUpByUser(String userId);
}