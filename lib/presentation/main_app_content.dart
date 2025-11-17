// lib/presentation/main_app_content.dart
import 'dart:io';

import 'package:chashview/presentation/viewmodels/main_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routing/main_router.dart';
import '../di/injection_container.dart';
import 'widgets/app_bar_widget.dart';
import 'widgets/bottom_nav_bar.dart';

class MainAppContent extends StatelessWidget {
  const MainAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MainViewModel>(),
      child: Consumer<MainViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: const AppBarWidget(),
            body: PopScope(
              canPop: false, // We handle back button manually
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  // System back button was pressed
                  _handleSystemBack(context, viewModel);
                }
              },
              child: Navigator(
                key: GlobalKey<NavigatorState>(),
                onGenerateRoute: MainRouter.onGenerateRoute,
                initialRoute: viewModel.currentSubRoute,
              ),
            ),
            bottomNavigationBar:
            viewModel.showBottomNav
                ? BottomNavBar(
              currentIndex: viewModel.currentIndex,
              onTap: (index) => viewModel.setTab(index),
            )
                : null,
          );
        },
      ),
    );
  }

  void _handleSystemBack(BuildContext context, MainViewModel viewModel) {
    if (viewModel.showBackButton) {
      // If we're in a sub-route (like lesson screens), use viewModel to go back
      viewModel.goBack();
    } else {
      // If we're in main tab, check if we can pop the navigator
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        // If nothing to pop, let system handle (might exit app)
        // Or you can show exit confirmation dialog
        _exitApp();
      }
    }
  }

  void _exitApp() {
    // Immediately exit the app without confirmation
    exit(0);
  }
}