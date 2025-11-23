import '../../domain/entities/title_entity.dart';
import '../../domain/repositories/title_repository.dart';
import '../datasources/title_remote_data_source.dart';
import '../models/title_model.dart';

class TitleRepositoryImpl implements TitleRepository {
  final TitleRemoteDataSource remoteDataSource;

  TitleRepositoryImpl(this.remoteDataSource);

  TitleModel _toModel(TitleEntity e) =>
      TitleModel(id: e.id, name: e.name, categoryId: e.categoryId, bookmark: e.bookmark);

  @override
  Future<void> createTitle(
    String userId,
    String type,
    TitleEntity title,
  ) async {
    await remoteDataSource.createTitle(userId, type, _toModel(title));
  }

  @override
  Future<List<TitleEntity>> getTitles(String userId, String type) async {
    final models = await remoteDataSource.getTitles(userId, type);
    return models
        .map((e) => TitleEntity(id: e.id, name: e.name, categoryId: e.categoryId, bookmark: e.bookmark))
        .toList();
  }

  @override
  Future<void> updateTitle(
    String userId,
    String type,
    TitleEntity title,
  ) async {
    await remoteDataSource.updateTitle(userId, type, _toModel(title));
  }

  @override
  Future<void> deleteTitle(String userId, String type, String titleId) async {
    await remoteDataSource.deleteTitle(userId, type, titleId);
  }

  @override
  Stream<List<TitleEntity>> listenTitles(String userId, String type) {
    return remoteDataSource.listenTitles(userId, type).map((models) {
      return models
          .map((e) => TitleEntity(id: e.id, name: e.name, categoryId: e.categoryId, bookmark: e.bookmark))
          .toList();
    });
  }
}
