import 'dart:async';
import 'package:async/async.dart';
import 'calculate_total_income_usecase.dart';
import 'calculate_total_expense_usecase.dart';

class CalculateNetUseCase {
  final CalculateTotalIncomeUseCase totalIncomeUseCase;
  final CalculateTotalExpenseUseCase totalExpenseUseCase;

  CalculateNetUseCase(this.totalIncomeUseCase, this.totalExpenseUseCase);

  /// 🔥 Realtime net calculation (supports ALL TIME)
  Stream<double> callRealtime(String userId, DateTime? start, DateTime? end) {
    final incomeStream = totalIncomeUseCase.callRealtime(userId, start, end);
    final expenseStream = totalExpenseUseCase.callRealtime(userId, start, end);

    return StreamZip([incomeStream, expenseStream]).map((values) {
      final income = values[0];
      final expense = values[1];
      return income - expense;
    });
  }

  /// One-time fetch version (supports ALL TIME)
  Future<double> call(String userId, DateTime? start, DateTime? end) async {
    final income = await totalIncomeUseCase.call(userId, start, end);
    final expense = await totalExpenseUseCase.call(userId, start, end);
    return income - expense;
  }
}
