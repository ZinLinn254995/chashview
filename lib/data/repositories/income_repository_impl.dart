import 'dart:async';

import '../../domain/entities/income_entity.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/income_remote_data_source.dart';
import '../models/income_model.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDataSource remoteDataSource;

  IncomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createIncome(String userId, IncomeEntity income) async {
    final model = _toModel(income);
    await remoteDataSource.createIncome(userId, model);
  }

  @override
  Future<List<IncomeEntity>> getIncomes(String userId) async {
    final models = await remoteDataSource.getIncomes(userId);
    // IncomeModel extends IncomeEntity so returning models is OK
    return models;
  }

  @override
  Future<void> updateIncome(String userId, IncomeEntity income) async {
    final model = _toModel(income);
    await remoteDataSource.updateIncome(userId, model);
  }

  @override
  Future<void> deleteIncome(String userId, String incomeId) async {
    await remoteDataSource.deleteIncome(userId, incomeId);
  }

  @override
  Stream<List<IncomeEntity>> listenIncomes(String userId) {
    return remoteDataSource.listenIncomes(userId)
    // map IncomeModel -> IncomeEntity (same type here)
        .map<List<IncomeEntity>>((models) => models);
  }

  IncomeModel _toModel(IncomeEntity e) {
    return IncomeModel(
      id: e.id,
      titleId: e.titleId,
      amount: e.amount,
      date: e.date,
      createdAt: e.createdAt,
    );
  }
}
