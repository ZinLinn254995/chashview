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

  List<TitleEntity> titles = [];
  bool isLoading = false;

  String? _currentType;
  StreamSubscription<List<TitleEntity>>? _sub;
  bool _isListening = false;

  TitleViewModel({
    required this.authViewModel,
    required this.createTitleUseCase,
    required this.getTitlesUseCase,
    required this.updateTitleUseCase,
    required this.deleteTitleUseCase,
    required this.listenTitlesUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    titles = [];
    notifyListeners();
    // User ပြောင်း/ထွက်သွားပါက ရှိနေဆဲ _currentType အတွက် Realtime Subscription ကို ပြန်စစ်/ပြန်ဖွင့်
    if (_currentType != null) subscribeToTitles(_currentType!);
  }

  void subscribeToTitles(String type) {
    _sub?.cancel();
    _sub = null;
    _isListening = false;

    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    //isLoading = true;
    //notifyListeners();

    _sub = listenTitlesUseCase.call(uid, type).listen(
          (list) {
        titles = list;
        _isListening = true;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isListening = false;
        isLoading = false;
        // Error handling logic ထပ်ထည့်နိုင်သည်
        notifyListeners();
      },
    );
  }

  Future<void> loadTitles(String type) async {
    _currentType = type;
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    titles = await getTitlesUseCase.call(userId: uid, type: type);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTitle(
      String type,
      String name,
      String categoryId // 🔥 NEW: categoryId input အဖြစ် လက်ခံပါ
      ) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    // Duplicate name စစ်ဆေးခြင်း
    final exists = titles.any((t) => t.name.toLowerCase() == name.toLowerCase());
    if (exists) return;

    // Use Case ကို name နဲ့ categoryId တို့ဖြင့် ခေါ်ဆိုပါမည်
    await createTitleUseCase.call(
      userId: uid,
      type: type,
      name: name,         // 🔥 Use Case အတွက် name ကို တိုက်ရိုက်ပေး
      categoryId: categoryId, // 🔥 Use Case အတွက် categoryId ကို တိုက်ရိုက်ပေး
      // TitleEntity object ကို ဒီနေရာမှာ ဖန်တီးတော့မည်မဟုတ်ပါ
    );

  }

  Future<void> editTitleName(String type, String titleId, String newName) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    final existing = titles.firstWhere((t) => t.id == titleId);
    // name ကိုသာ ပြောင်းလဲသည်၊ bookmark အခြေအနေ မပြောင်းလဲပါ
    final updated = existing.copyWith(name: newName);

    await updateTitleUseCase.call(userId: uid, type: type, title: updated);

  }

  Future<void> removeTitle(String type, String titleId) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await deleteTitleUseCase.call(userId: uid, type: type, titleId: titleId);

  }

  Future<void> toggleTitleBookmark(String type, String titleId, bool isBookmark) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;


    final index = titles.indexWhere((t) => t.id == titleId);
    if (index != -1) {
      titles[index] = titles[index].copyWith(bookmark: isBookmark);
      notifyListeners(); // UI ကို ချက်ချင်း update လုပ်
    }

    await updateTitleUseCase.call(
        userId: uid,
        type: type,
        title: titles[index] // ပြင်ပြီးသား data ကို ပို့
    );

  }

  @override
  void dispose() {
    _sub?.cancel(); // Realtime Subscription ကို ပိတ်သည်
    authViewModel.onUserChanged.removeListener(_handleUserChanged); // Listener ဖြုတ်သည်
    super.dispose();
  }
}