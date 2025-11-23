import 'dart:async';
import '../../../core/services/firebase_service.dart';
import '../../../core/constants/firebase_paths.dart';
import '../models/expense_model.dart';
import 'package:firebase_database/firebase_database.dart';

class ExpenseRemoteDataSource {
  final FirebaseService firebaseService;

  ExpenseRemoteDataSource(this.firebaseService);

  Future<void> createExpense(String userId, ExpenseModel model) async {
    await firebaseService
        .ref('${FirebasePaths.expense(userId)}/${model.id}')
        .set(model.toJson());
  }

  Future<List<ExpenseModel>> getExpenses(String userId) async {
    final snapshot = await firebaseService.getData(FirebasePaths.expense(userId));

    if (!snapshot.exists || snapshot.value == null) return [];

    final map = snapshot.value as Map<dynamic, dynamic>;

    return map.entries.map((e) {
      return ExpenseModel.fromJson(
        Map<String, dynamic>.from(e.value),
        e.key,
      );
    }).toList();
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

  /// 🔥 REALTIME LISTEN
  Stream<List<ExpenseModel>> listenExpenses(String userId) {
    final path = FirebasePaths.expense(userId);

    return firebaseService.listenToPath(path).map((DatabaseEvent event) {
      final snap = event.snapshot;

      if (!snap.exists) return <ExpenseModel>[];

      final children = snap.children;

      final list = <ExpenseModel>[];

      for (final child in children) {
        if (child.value == null) continue;

        try {
          final json = Map<String, dynamic>.from(child.value as Map);
          list.add(ExpenseModel.fromJson(json, child.key!));
        } catch (_) {}
      }

      return list;
    });
  }
}
