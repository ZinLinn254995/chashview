import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/main_viewmodel.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      // Background color from theme (surface container recommended for M3)
      backgroundColor: colorScheme.surface,

      // Elevation from theme's AppBarTheme will be used by default

      leading: viewModel.showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        color: colorScheme.onSurfaceVariant,
        onPressed: () => viewModel.goBack(),
      )
          : null,
      title: Text(
        viewModel.title,
        style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      actions: [
        if (!viewModel.showBackButton)
          IconButton(
            icon: const Icon(Icons.settings), // or your custom icon
            color: colorScheme.onSurfaceVariant,
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
