// lib/data/datasources/top_up_remote_data_source.dart
import '../../domain/entities/top_up_entity.dart';
import '../models/top_up_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

abstract class TopUpRemoteDataSource {
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

class TopUpRemoteDataSourceImpl implements TopUpRemoteDataSource {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final Random _random = Random();

  // Generate unique code: ABCD-1234 format
  String _generateTopUpCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const nums = '0123456789';

    String letters = '';
    for (int i = 0; i < 4; i++) {
      letters += chars[_random.nextInt(chars.length)];
    }

    String numbers = '';
    for (int i = 0; i < 4; i++) {
      numbers += nums[_random.nextInt(nums.length)];
    }

    return '$letters-$numbers';
  }

  @override
  Future<TopUpEntity> generateTopUpCode({
    required String planId,
    required String adminId,
    required String expireAt,
  }) async {
    try {
      String code;
      bool exists;

      do {
        code = _generateTopUpCode();
        final snapshot = await _dbRef.child('topUps').child(code).get();
        exists = snapshot.exists;
      } while (exists);

      final topUp = TopUpEntity(
        code: code,
        planId: planId,
        generatedByAdmin: adminId,
        expireAt: expireAt,
        usedByUserId: null,
        usedAt: null,
        status: TopUpStatus.active,
      );

      final topUpModel = TopUpModel(
        code: code,
        planId: planId,
        generatedByAdmin: adminId,
        expireAt: expireAt,
        usedByUserId: null,
        usedAt: null,
        status: TopUpStatus.active,
      );

      // 🔥 ပြင်ဆင်ချက်: toMap() ပြီးမှ status ကို String ('active') အနေနဲ့ သေချာ update လုပ်ပါ
      final Map<String, dynamic> dataToSave = topUpModel.toMap();
      dataToSave['status'] = 'active'; // သို့မဟုတ် TopUpStatus.active.name

      await _dbRef.child('topUps').child(code).set(dataToSave);
      return topUp;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TopUpEntity>> getTopUpCodes({
    String? status,
    String? planId,
  }) async {
    try {
      // 🔥 1. Query မလုပ်တော့ဘဲ Data အကုန်လုံးကို အရင်လှမ်းယူလိုက်ပါ (orderByChild ကို ဖြုတ်လိုက်တာပါ)
      final snapshot = await _dbRef.child('topUps').get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      List<TopUpEntity> topUps = [];

      data.forEach((key, value) {
        try {
          final topUpMap = value as Map<dynamic, dynamic>;
          final topUp = TopUpModel.fromMap({
            ...topUpMap,
            'code': key.toString(),
          }).toEntity();
          topUps.add(topUp);
        } catch (e) {
          // Parsing error (optional: print(e))
        }
      });

      // 🔥 2. Data အကုန်ရမှ Dart Code နဲ့ စစ်ထုတ်ပါ (Client-side Filtering)

      // Status နဲ့ စစ်ခြင်း
      if (status != null) {
        // Database ထဲက Enum.name နဲ့ တိုက်စစ်ပါ (ဥပမာ: 'active')
        topUps = topUps.where((item) => item.status.name == status).toList();
      }

      // Plan ID နဲ့ စစ်ခြင်း
      if (planId != null) {
        topUps = topUps.where((item) => item.planId == planId).toList();
      }

      // Sort လုပ်ချင်ရင်လည်း ဒီမှာတင် လုပ်လို့ရပါတယ် (ဥပမာ - နောက်ဆုံးထုတ်တာ အပေါ်တင်ချင်ရင်)
      // topUps.sort((a, b) => b.expireAt.compareTo(a.expireAt));

      return topUps;
    } catch (e) {
      // print('Error fetching top-up codes: $e');
      return [];
    }
  }

  @override
  Future<TopUpEntity?> getTopUpByCode(String code) async {
    try {
      final snapshot = await _dbRef.child('topUps').child(code).get();
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return TopUpModel.fromMap({
        ...data,
        'code': code,
      }).toEntity();
    } catch (e) {
      //print('Error fetching top-up by code: $e');
      return null;
    }
  }

  @override
  Future<TopUpEntity> validateTopUpCode(String code) async {
    try {
      final topUp = await getTopUpByCode(code);
      if (topUp == null) {
        throw Exception('Invalid top-up code');
      }

      if (topUp.status != TopUpStatus.active) {
        throw Exception('Top-up code is not active');
      }

      if (topUp.usedByUserId != null) {
        throw Exception('Top-up code already used');
      }

      // Check expiration
      final expireDate = DateTime.parse(topUp.expireAt);
      if (DateTime.now().isAfter(expireDate)) {
        throw Exception('Top-up code has expired');
      }

      return topUp;
    } catch (e) {
      //print('Error validating top-up code: $e');
      rethrow;
    }
  }

  @override
  Future<void> redeemTopUpCode({
    required String code,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      await _dbRef.child('topUps').child(code).update({
        'usedByUserId': userId,
        'usedAt': now.toIso8601String(),
        'status': TopUpStatus.used.name,
      });
    } catch (e) {
      //print('Error redeeming top-up code: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTopUp(TopUpEntity topUp) async {
    try {
      final topUpModel = TopUpModel(
        code: topUp.code,
        planId: topUp.planId,
        generatedByAdmin: topUp.generatedByAdmin,
        expireAt: topUp.expireAt,
        usedByUserId: topUp.usedByUserId,
        usedAt: topUp.usedAt,
        status: topUp.status,
      );

      await _dbRef.child('topUps').child(topUp.code).update(topUpModel.toMap());
    } catch (e) {
      //print('Error updating top-up: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTopUpStatus({
    required String code,
    required String status,
  }) async {
    try {
      await _dbRef.child('topUps').child(code).update({
        'status': status,
      });
    } catch (e) {
      //print('Error updating top-up status: $e');
      rethrow;
    }
  }

  @override
  Future<List<TopUpEntity>> getTopUpByUser(String userId) async {
    try {
      final snapshot = await _dbRef.child('topUps')
          .orderByChild('usedByUserId')
          .equalTo(userId)
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<TopUpEntity> topUps = [];

      data.forEach((key, value) {
        try {
          final topUpMap = value as Map<dynamic, dynamic>;
          final topUp = TopUpModel.fromMap({
            ...topUpMap,
            'code': key.toString(),
          }).toEntity();
          topUps.add(topUp);
        } catch (e) {
          //print('Error parsing top-up $key: $e');
        }
      });

      return topUps;
    } catch (e) {
      //print('Error fetching top-ups by user: $e');
      return [];
    }
  }
}