// lib/presentation/main_app_content.dart
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
            body: Navigator(
              key: GlobalKey<NavigatorState>(),
              onGenerateRoute: MainRouter.onGenerateRoute,
              initialRoute: viewModel.currentSubRoute,
            ),
            bottomNavigationBar:
            viewModel.showBottomNav // 👈 hide/show logic
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
}
