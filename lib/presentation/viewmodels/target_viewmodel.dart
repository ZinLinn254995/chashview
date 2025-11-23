import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/target_entity.dart';
import '../../domain/usecases/target/create_target_usecase.dart';
import '../../domain/usecases/target/get_targets_usecase.dart';
import '../../domain/usecases/target/update_target_usecase.dart';
import '../../domain/usecases/target/delete_target_usecase.dart';
import '../../domain/usecases/target/listen_targets_usecase.dart';
import 'auth_viewmodel.dart';

class TargetViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateTargetUseCase createTargetUseCase;
  final GetTargetsUseCase getTargetsUseCase;
  final UpdateTargetUseCase updateTargetUseCase;
  final DeleteTargetUseCase deleteTargetUseCase;
  final ListenTargetsUseCase listenTargetsUseCase;

  List<TargetEntity> targets = [];
  bool isLoading = false;

  StreamSubscription<List<TargetEntity>>? _sub;
  bool _isListening = false;

  TargetViewModel({
    required this.authViewModel,
    required this.createTargetUseCase,
    required this.getTargetsUseCase,
    required this.updateTargetUseCase,
    required this.deleteTargetUseCase,
    required this.listenTargetsUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
    _subscribe();
  }

  void _handleUserChanged() {
    targets = [];
    notifyListeners();
    _subscribe();
  }

  /// 🔥 subscribe to realtime updates
  void _subscribe() {
    _sub?.cancel();
    _sub = null;
    _isListening = false;

    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    _sub = listenTargetsUseCase.call(uid).listen(
          (list) {
        targets = list;
        _isListening = true;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isListening = false;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  /// fallback fetch
  Future<void> loadTargets() async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    targets = await getTargetsUseCase.call(uid);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTarget(TargetEntity entity) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await createTargetUseCase.call(uid, entity);

    if (!_isListening) await loadTargets();
  }

  Future<void> editTarget(TargetEntity entity) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await updateTargetUseCase.call(uid, entity);

    if (!_isListening) await loadTargets();
  }

  Future<void> removeTarget(String id) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await deleteTargetUseCase.call(uid, id);

    if (!_isListening) await loadTargets();
  }

  @override
  void dispose() {
    _sub?.cancel();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}
