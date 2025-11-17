import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/income_entity.dart';

class IncomeTotalService {
  final _db = FirebaseDatabase.instance.ref();

  Future<double> getIncomeTotal(String userId) async {
    final snapshot = await _db.child("users/$userId/incomes").get();

    if (!snapshot.exists) return 0.0;

    double total = 0.0;

    for (final child in snapshot.children) {
      final data = Map<String, dynamic>.from(child.value as Map);
      final amount = (data["amount"] ?? 0).toDouble();
      total += amount;
    }

    return total;
  }
}
