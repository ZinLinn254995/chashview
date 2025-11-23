import 'dart:async';
import '../../repositories/expense_repository.dart';
import '../../entities/expense_entity.dart';

class CalculateTotalExpenseUseCase {
  final ExpenseRepository expenseRepo;

  CalculateTotalExpenseUseCase(this.expenseRepo);

  /// 🔥 Realtime stream version (supports ALL TIME)
  Stream<double> callRealtime(String userId, DateTime? start, DateTime? end) {
    return expenseRepo.listenExpenses(userId).map((List<ExpenseEntity> expenses) {
      return expenses
          .where((e) {
        if (start != null && e.date.isBefore(start)) return false;
        if (end != null && e.date.isAfter(end)) return false;
        return true;
      })
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    });
  }

  /// One-time fetch version (supports ALL TIME)
  Future<double> call(String userId, DateTime? start, DateTime? end) async {
    final expenses = await expenseRepo.getExpenses(userId);
    return expenses
        .where((e) {
      if (start != null && e.date.isBefore(start)) return false;
      if (end != null && e.date.isAfter(end)) return false;
      return true;
    })
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }
}
