import 'dart:async';
import '../../repositories/income_repository.dart';
import '../../entities/income_entity.dart';

class CalculateTotalIncomeUseCase {
  final IncomeRepository incomeRepo;

  CalculateTotalIncomeUseCase(this.incomeRepo);

  /// 🔥 Realtime stream version (supports ALL TIME)
  Stream<double> callRealtime(String userId, DateTime? start, DateTime? end) {
    return incomeRepo.listenIncomes(userId).map((List<IncomeEntity> incomes) {
      return incomes
          .where((i) {
        if (start != null && i.date.isBefore(start)) return false;
        if (end != null && i.date.isAfter(end)) return false;
        return true;
      })
          .fold<double>(0.0, (sum, i) => sum + i.amount);
    });
  }

  /// One-time fetch version (supports ALL TIME)
  Future<double> call(String userId, DateTime? start, DateTime? end) async {
    final incomes = await incomeRepo.getIncomes(userId);
    return incomes
        .where((i) {
      if (start != null && i.date.isBefore(start)) return false;
      if (end != null && i.date.isAfter(end)) return false;
      return true;
    })
        .fold<double>(0.0, (sum, i) => sum + i.amount);
  }
}
