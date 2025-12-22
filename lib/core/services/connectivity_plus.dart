// lib/core/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Stream for connectivity changes
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    // Initial check
    await _checkAndNotify();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _isConnected = !results.contains(ConnectivityResult.none);
      _connectionController.add(_isConnected);
    });
  }

  Future<bool> _checkAndNotify() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = !results.contains(ConnectivityResult.none);
    _connectionController.add(_isConnected);
    return _isConnected;
  }

  Future<bool> checkConnection() async {
    return await _checkAndNotify();
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}