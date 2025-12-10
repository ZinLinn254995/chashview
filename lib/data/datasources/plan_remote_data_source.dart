// lib/data/datasources/plan_remote_data_source.dart

import '../../domain/entities/plan_entity.dart';
import '../models/plan_model.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class PlanRemoteDataSource {
  Future<List<PlanEntity>> getPlans();
  Future<PlanEntity?> getPlanById(String planId);
  Future<void> createPlan(PlanEntity plan); // Plan ID ကို auto-generate လုပ်မည်
  Future<void> updatePlan(PlanEntity plan);
  Future<void> deletePlan(String planId);
}

class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  Future<List<PlanEntity>> getPlans() async {
    try {
      final snapshot = await _dbRef.child('plans').get();
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<PlanEntity> plans = [];

      data.forEach((key, value) {
        try {
          final planMap = value as Map<dynamic, dynamic>;
          // PlanModel.fromMap သည် planMap ထဲမှ data များကို ဖတ်ပြီး Entity/Model ကို ပြန်ပေးသည်။
          final plan = PlanModel.fromMap({
            ...planMap,
            // key ကို planId အဖြစ် ထည့်သွင်းစရာ မလိုတော့ပါ၊ dataToSave မှာ ပါပြီးသားဖြစ်၍
            // (သို့သော် ယခင်ကုဒ်အတိုင်း key ကို အသုံးပြု၍ ID ပေးနိုင်ပါသည်)
            'planId': key.toString(),
          }).toEntity();
          plans.add(plan);
        } catch (e) {
          print('Error parsing plan $key: $e');
        }
      });

      return plans;
    } catch (e) {
      print('Error fetching plans: $e');
      // Production မှာ empty list မပြန်ဘဲ error ကို ပြန်လွှင့်ထုတ်သင့်သည်။
      return [];
    }
  }

  @override
  Future<PlanEntity?> getPlanById(String planId) async {
    try {
      final snapshot = await _dbRef.child('plans').child(planId).get();
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return PlanModel.fromMap({
        ...data,
        'planId': planId,
      }).toEntity();
    } catch (e) {
      print('Error fetching plan by ID: $e');
      return null;
    }
  }

  // 🔥 ID Auto-Generation အတွက် ပြင်ဆင်လိုက်သော Method
  @override
  Future<void> createPlan(PlanEntity plan) async {
    try {
      // 1. Plan ID မပါသေးသည့် PlanModel ကို တည်ဆောက်ခြင်း
      // (PlanModel constructor မှာ planId ကို String? အဖြစ် ယူဆထားပါသည်)
      final planModel = PlanModel(
        planId: '', // ID ကို Database မှ ထုတ်ပေးမည့်အတွက် null ထားသည်။
        name: plan.name,
        price: plan.price,
        type: plan.type,
      );

      // 2. 💡 .push() ကို အသုံးပြုပြီး ID အသစ် ရယူခြင်း (Auto-generation)
      final newPlanRef = _dbRef.child('plans').push();

      final newPlanId = newPlanRef.key;
      if (newPlanId == null) {
        throw Exception('Failed to generate new plan ID for Firebase.');
      }

      // 3. Data Map ထဲမှာ ထုတ်ပေးလိုက်သော ID ကိုပါ ထည့်သွင်းခြင်း
      // (Database ထဲမှာ Data ကို key/value တွဲလျက် သိမ်းဆည်းရန်)
      final Map<String, dynamic> dataToSave = planModel.toMap();
      dataToSave['planId'] = newPlanId;

      // 4. Database တွင် သိမ်းဆည်းခြင်း
      await newPlanRef.set(dataToSave);

    } catch (e) {
      print('Error creating plan: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePlan(PlanEntity plan) async {
    try {
      if (plan.planId.isEmpty) {
        throw Exception('Plan ID is required for update operation.');
      }

      final planModel = PlanModel(
        planId: plan.planId,
        name: plan.name,
        price: plan.price,
        type: plan.type,
      );

      // planModel.toMap() သည် type.name (String key) ကို Database တွင် update လုပ်သွားပါမည်။
      // update() သည် ပေးပို့သော fields များကိုသာ ပြောင်းလဲပေးသည်။
      await _dbRef.child('plans').child(plan.planId).update(planModel.toMap());
    } catch (e) {
      print('Error updating plan: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePlan(String planId) async {
    try {
      await _dbRef.child('plans').child(planId).remove();
    } catch (e) {
      print('Error deleting plan: $e');
      rethrow;
    }
  }
}