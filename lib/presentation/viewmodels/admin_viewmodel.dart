// lib/presentation/viewmodels/admin_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/get_all_users_usecase.dart';
import '../../domain/usecases/auth/update_user_role_usecase.dart';
import '../../domain/usecases/auth/update_user_status_usecase.dart';

class AdminViewModel extends ChangeNotifier {
  final GetAllUsersUseCase getAllUsersUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final UpdateUserStatusUseCase updateUserStatusUseCase;

  List<UserEntity> _users = [];
  List<UserEntity> get users => _users;

  UserEntity? _selectedUser;
  UserEntity? get selectedUser => _selectedUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  AdminViewModel({
    required this.getAllUsersUseCase,
    required this.updateUserRoleUseCase,
    required this.updateUserStatusUseCase,
  });

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _users = await getAllUsersUseCase.call();
    } catch (e) {
      _errorMessage = 'Failed to load users: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await updateUserRoleUseCase.call(userId, newRole);
      await loadAllUsers(); // Refresh list
      _successMessage = 'User role updated successfully';
    } catch (e) {
      _errorMessage = 'Failed to update user role: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserStatus(String userId, UserStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await updateUserStatusUseCase.call(userId, newStatus);
      await loadAllUsers(); // Refresh list
      _successMessage = 'User status updated successfully';
    } catch (e) {
      _errorMessage = 'Failed to update user status: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectUser(String userId) async {
    try {
      _selectedUser = _users.firstWhere((user) => user.uid == userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'User not found: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}