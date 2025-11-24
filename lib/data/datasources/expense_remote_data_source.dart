import 'dart:async';
import '../../../core/services/firebase_service.dart';
import '../../../core/constants/firebase_paths.dart';
import '../models/expense_model.dart';
import 'package:firebase_database/firebase_database.dart';

class ExpenseRemoteDataSource {
  final FirebaseService firebaseService;

  ExpenseRemoteDataSource(this.firebaseService);

  /// 🔥 FIX: Push/Auto ID ကို သုံးပြီး List ထဲကို ထည့်ပါ
  Future<void> createExpense(String userId, ExpenseModel model) async {
    final ref = firebaseService.ref(FirebasePaths.expense(userId)).push();
    await ref.set(model.toJson());
  }

  // 🔥 ဒီ Function ကို အဓိက ပြင်ထားပါတယ်
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final snapshot = await firebaseService.getData(FirebasePaths.expense(userId));

    if (!snapshot.exists || snapshot.value == null) return [];

    final dynamic data = snapshot.value;

    // ၁။ Data က Map ဟုတ်မဟုတ် အရင်စစ်ပါတယ်
    if (data is Map) {
      return data.entries.map((e) {
        final dynamic val = e.value;

        // ၂။ ပြဿနာတက်စေတဲ့နေရာ (String is not subtype of Map Error ကို ကာကွယ်ခြင်း)
        // Data တစ်ခုချင်းစီက Map ဟုတ်မှသာ Model ပြောင်းမယ်၊ String/Int ဖြစ်နေရင် Null ပြန်မယ်
        if (val is Map) {
          try {
            return ExpenseModel.fromJson(
              Map<String, dynamic>.from(val),
              e.key.toString(),
            );
          } catch (e) {
            // Parsing Error ရှိရင်လည်း ကျော်သွားမယ်
            return null;
          }
        }
        return null; // Bad data (String) ဆိုရင် null ပြန်မယ်
      })
      // ၃။ Null ဖြစ်နေတဲ့ (Bad Data) တွေကို စစ်ထုတ်လိုက်မယ်
          .where((element) => element != null)
          .cast<ExpenseModel>()
          .toList();
    }

    return [];
  }

  Future<void> updateExpense(String userId, ExpenseModel model) async {
    await firebaseService
        .ref('${FirebasePaths.expense(userId)}/${model.id}')
        .update(model.toJson());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await firebaseService
        .ref('${FirebasePaths.expense(userId)}/$expenseId')
        .remove();
  }

  /// 🔥 REALTIME LISTEN (ဒီနေရာကို အဓိက ပြင်ပါ)
  Stream<List<ExpenseModel>> listenExpenses(String userId) {
    final path = FirebasePaths.expense(userId);

    return firebaseService.listenToPath(path).map((DatabaseEvent event) {
      final snap = event.snapshot;

      if (!snap.exists) return <ExpenseModel>[];

      final children = snap.children;
      final list = <ExpenseModel>[];

      for (final child in children) {
        if (child.value == null) continue;

        // 🔥 FIX: Data Type ကို သေချာစစ်ဆေးပါ
        // String/Int တွေပါလာရင် Error မတက်စေဘဲ Map ဖြစ်မှသာ ယူပါမယ်
        if (child.value is Map) {
          try {
            final json = Map<String, dynamic>.from(child.value as Map);
            list.add(ExpenseModel.fromJson(json, child.key!));
          } catch (e) {
            // Parsing error ရှိရင် ကျော်သွားမယ် (Log ထုတ်ကြည့်နိုင်သည်)
            print("Expense Parsing Error: $e");
          }
        }
      }

      return list;
    });
  }
}