import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../core/routing/app_router.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    // ပထမဆုံး အကြိမ် စစ်ဆေးခြင်း
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        _showNoInternetDialog();
      }
    });

    // Connection ပြောင်းလဲမှုကို အမြဲနားထောင်ခြင်း
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        _showNoInternetDialog();
      } else {
        _dismissDialog();
      }
    });
  }

  void _showNoInternetDialog() {
    // AppRouter ထဲက navigatorKey context ကို ယူသုံးခြင်း
    final navContext = AppRouter.navigatorKey.currentContext;

    if (_isDialogShowing || navContext == null) return;

    _isDialogShowing = true;

    showDialog(
      context: navContext,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Back key နဲ့ ပိတ်လို့မရအောင် လုပ်ခြင်း
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 10),
              Text('No Connection'),
            ],
          ),
          content: const Text(
            'It looks like you are offline. Please check your internet connection.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final results = await _connectivity.checkConnectivity();
                if (!results.contains(ConnectivityResult.none)) {
                  _dismissDialog();
                }
              },
              child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _dismissDialog() {
    if (_isDialogShowing) {
      final navContext = AppRouter.navigatorKey.currentContext;
      if (navContext != null) {
        Navigator.of(navContext, rootNavigator: true).pop();
      }
      _isDialogShowing = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}