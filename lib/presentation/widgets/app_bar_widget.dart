import 'package:flutter/material.dart';
import '../../../core/routing/route_names.dart';
import '../../core/constants/app_sizes.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      leading: null,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          color: colorScheme.onSurface,
          onPressed: () {
            // AppRouter မှာ သတ်မှတ်ထားတဲ့ Settings route ကို ခေါ်ပါမယ်
            Navigator.pushNamed(context, RouteNames.settings);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}