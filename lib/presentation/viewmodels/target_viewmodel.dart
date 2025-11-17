import 'package:flutter/foundation.dart';
import '../../domain/entities/target_entity.dart';
import '../../domain/usecases/target/create_target_usecase.dart';
import '../../domain/usecases/target/get_targets_usecase.dart';
import '../../domain/usecases/target/update_target_usecase.dart';
import '../../domain/usecases/target/delete_target_usecase.dart';
import 'auth_viewmodel.dart';

class TargetViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateTargetUseCase createTargetUseCase;
  final GetTargetsUseCase getTargetsUseCase;
  final UpdateTargetUseCase updateTargetUseCase;
  final DeleteTargetUseCase deleteTargetUseCase;

  List<TargetEntity> targets = [];
  bool isLoading = false;

  TargetViewModel({
    required this.authViewModel,
    required this.createTargetUseCase,
    required this.getTargetsUseCase,
    required this.updateTargetUseCase,
    required this.deleteTargetUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    targets = [];
    notifyListeners();
    loadTargets();
  }

  Future<void> loadTargets() async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    targets = await getTargetsUseCase.call(uid);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTarget(TargetEntity target) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await createTargetUseCase.call(uid, target);
    await loadTargets();
  }

  Future<void> editTarget(TargetEntity target) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await updateTargetUseCase.call(uid, target);
    await loadTargets();
  }

  Future<void> removeTarget(String id) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await deleteTargetUseCase.call(uid, id);
    await loadTargets();
  }
}
