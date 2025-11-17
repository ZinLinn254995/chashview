import 'package:flutter/foundation.dart';
import '../../../domain/entities/title_entity.dart';
import '../../domain/usecases/title/create_title_usecase.dart';
import '../../domain/usecases/title/get_titles_usecase.dart';
import '../../domain/usecases/title/update_title_usecase.dart';
import '../../domain/usecases/title/delete_title_usecase.dart';
import 'auth_viewmodel.dart';

class TitleViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;
  final CreateTitleUseCase createTitleUseCase;
  final GetTitlesUseCase getTitlesUseCase;
  final UpdateTitleUseCase updateTitleUseCase;
  final DeleteTitleUseCase deleteTitleUseCase;

  List<TitleEntity> titles = [];
  bool isLoading = false;

  String? _currentType;

  TitleViewModel({
    required this.authViewModel,
    required this.createTitleUseCase,
    required this.getTitlesUseCase,
    required this.updateTitleUseCase,
    required this.deleteTitleUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    titles = [];
    notifyListeners();
    if (_currentType != null) loadTitles(_currentType!);
  }

  Future<void> loadTitles(String type) async {
    _currentType = type;
    final userId = authViewModel.user?.uid;
    if (userId == null) {
      titles = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    titles = await getTitlesUseCase.call(userId: userId, type: type);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTitle(String type, String name) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    final exists = titles.any((t) => t.name.toLowerCase() == name.toLowerCase());
    if (exists) return;

    await createTitleUseCase.call(
      userId: userId,
      type: type,
      title: TitleEntity(id: '', name: name),
    );

    await loadTitles(type);
  }

  /// Update a title (using copyWith for immutability)
  Future<void> editTitleName(String type, String titleId, String newName) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    final existing = titles.firstWhere((t) => t.id == titleId);
    final updated = existing.copyWith(name: newName);

    await updateTitleUseCase.call(userId: userId, type: type, title: updated);
    await loadTitles(type);
  }

  Future<void> removeTitle(String type, String titleId) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await deleteTitleUseCase.call(userId: userId, type: type, titleId: titleId);
    await loadTitles(type);
  }
}
