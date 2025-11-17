import '../../domain/entities/title_entity.dart';
import '../../domain/repositories/title_repository.dart';
import '../datasources/title_remote_data_source.dart';
import '../models/title_model.dart';

class TitleRepositoryImpl implements TitleRepository {
  final TitleRemoteDataSource remoteDataSource;

  TitleRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createTitle(String userId, String type, TitleEntity title) async {
    final model = TitleModel(id: title.id, name: title.name);
    await remoteDataSource.createTitle(userId, type, model);
  }

  @override
  Future<List<TitleEntity>> getTitles(String userId, String type) async {
    final models = await remoteDataSource.getTitles(userId, type);
    return models;
  }

  @override
  Future<void> updateTitle(String userId, String type, TitleEntity title) async {
    final model = TitleModel(id: title.id, name: title.name);
    await remoteDataSource.updateTitle(userId, type, model);
  }

  @override
  Future<void> deleteTitle(String userId, String type, String titleId) async {
    await remoteDataSource.deleteTitle(userId, type, titleId);
  }
}
