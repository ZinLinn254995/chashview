// lib/presentation/widgets/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/main_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_icons.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    return AppBar(
      backgroundColor: AppColors.backgroundPrimary,
      elevation: 2,
      leading: viewModel.showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textWhite,
        onPressed: () => viewModel.goBack(),
      )
          : null,
      title: Text(
        viewModel.title,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: AppFontSize.lg,
          fontWeight: AppFontWeight.bold,
        ),
      ),
      actions: [
        if (!viewModel.showBackButton) // Back page မှာတော့ hide
          IconButton(
            icon: const Icon(AppIcons.setting),
            color: AppColors.textWhite,
            onPressed: () {
              viewModel.navigateTo('/settings',
                  title: 'Settings', hideBottomNav: true);
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
