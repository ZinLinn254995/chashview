import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/title_entity.dart';
import '../../domain/usecases/title/create_title_usecase.dart';
import '../../domain/usecases/title/get_titles_usecase.dart';
import '../../domain/usecases/title/update_title_usecase.dart';
import '../../domain/usecases/title/delete_title_usecase.dart';
import '../../domain/usecases/title/listen_titles_usecase.dart';
import 'auth_viewmodel.dart';

class TitleViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;
  final CreateTitleUseCase createTitleUseCase;
  final GetTitlesUseCase getTitlesUseCase;
  final UpdateTitleUseCase updateTitleUseCase;
  final DeleteTitleUseCase deleteTitleUseCase;
  final ListenTitlesUseCase listenTitlesUseCase;

  List<TitleEntity> incomeTitles = [];
  List<TitleEntity> expenseTitles = [];

  bool isLoading = false;

  StreamSubscription<List<TitleEntity>>? _incomeSub;
  StreamSubscription<List<TitleEntity>>? _expenseSub;

  TitleViewModel({
    required this.authViewModel,
    required this.createTitleUseCase,
    required this.getTitlesUseCase,
    required this.updateTitleUseCase,
    required this.deleteTitleUseCase,
    required this.listenTitlesUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
    if (authViewModel.user != null) {
      _initStreams();
    }
  }

  void _handleUserChanged() {
    if (authViewModel.user == null) {
      incomeTitles = [];
      expenseTitles = [];
      _cancelStreams();
      notifyListeners();
    } else {
      _initStreams();
    }
  }

  void _initStreams() {
    _cancelStreams();
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    _incomeSub = listenTitlesUseCase.call(uid, 'income').listen((list) {
      incomeTitles = list;
      isLoading = false;
      notifyListeners();
    });

    _expenseSub = listenTitlesUseCase.call(uid, 'expense').listen((list) {
      expenseTitles = list;
      isLoading = false;
      notifyListeners();
    });
  }

  void _cancelStreams() {
    _incomeSub?.cancel();
    _expenseSub?.cancel();
  }

  List<TitleEntity> getTitlesByType(String type) {
    return type == 'income' ? incomeTitles : expenseTitles;
  }

  // CRUD Operations...
  Future<void> addTitle(String type, String name, String categoryId) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    final targetList = type == 'income' ? incomeTitles : expenseTitles;
    if (targetList.any((t) => t.name.toLowerCase() == name.toLowerCase())) return;

    await createTitleUseCase.call(
      userId: uid,
      type: type,
      name: name,
      categoryId: categoryId,
    );
  }

  Future<void> updateTitle({
    required String type,
    required TitleEntity title,
  }) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await updateTitleUseCase.call(
        userId: uid,
        type: type,
        title: title,
      );
    } catch (e) {
      debugPrint("Update Title Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTitleBookmark(String type, String titleId, bool isBookmark) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    final targetList = type == 'income' ? incomeTitles : expenseTitles;
    final index = targetList.indexWhere((t) => t.id == titleId);

    if (index != -1) {
      final updatedTitle = targetList[index].copyWith(bookmark: isBookmark);
      await updateTitleUseCase.call(userId: uid, type: type, title: updatedTitle);
    }
  }

  // 🔥 NEW: Added Cart Toggle Logic Here
  Future<void> toggleTitleCart(String type, String titleId, bool isCart) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    final targetList = type == 'income' ? incomeTitles : expenseTitles;
    final index = targetList.indexWhere((t) => t.id == titleId);

    if (index != -1) {
      final updatedTitle = targetList[index].copyWith(cart: isCart);
      await updateTitleUseCase.call(userId: uid, type: type, title: updatedTitle);
    }
  }

  Future<void> deleteTitleWithCascade({
    required String type,
    required String titleId,
    required List<String> relatedItemIds,
  }) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final dbRef = FirebaseDatabase.instance.ref();
      Map<String, dynamic> updates = {};

      final String titlePath = 'users/$uid/${type}Titles/$titleId';
      updates[titlePath] = null;

      final String itemRoot = type;

      for (var itemId in relatedItemIds) {
        updates['users/$uid/$itemRoot/$itemId'] = null;
      }

      await dbRef.update(updates);

    } catch (e) {
      debugPrint("❌ Title Cascade Delete Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancelStreams();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}