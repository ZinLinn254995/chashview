import 'dart:async';
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

  // 🔥 Change 1: List နှစ်ခုခွဲလိုက်ပါ (CategoryViewModel ကဲ့သို့)
  List<TitleEntity> incomeTitles = [];
  List<TitleEntity> expenseTitles = [];

  bool isLoading = false;

  // Streams
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
    // 🔥 Change 2: App စစချင်း User ရှိရင် Stream ဖွင့်မယ်
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

  // 🔥 Change 3: Stream တွေကို တပြိုင်နက် Listen လုပ်မယ်
  void _initStreams() {
    _cancelStreams();
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    // Listen Income Titles
    _incomeSub = listenTitlesUseCase.call(uid, 'income').listen((list) {
      incomeTitles = list;
      isLoading = false;
      notifyListeners();
    });

    // Listen Expense Titles
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

  // Method to get specific list
  List<TitleEntity> getTitlesByType(String type) {
    return type == 'income' ? incomeTitles : expenseTitles;
  }

  // CRUD Operations...
  Future<void> addTitle(String type, String name, String categoryId) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    // Check duplicates in specific list
    final targetList = type == 'income' ? incomeTitles : expenseTitles;
    if (targetList.any((t) => t.name.toLowerCase() == name.toLowerCase())) return;

    await createTitleUseCase.call(
      userId: uid,
      type: type,
      name: name,
      categoryId: categoryId,
    );
  }

  // ... (Update, Delete, ToggleBookmark functions remain mostly same but use type to navigate logic if needed,
  // though Stream handles the UI update automatically)

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

  @override
  void dispose() {
    _cancelStreams();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}