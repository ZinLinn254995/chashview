import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,

      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,

      selectedLabelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
      unselectedLabelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),

      items: const [
        BottomNavigationBarItem(
          icon: Icon(AppIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.income),
          label: 'Income',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.expense),
          label: 'Expense',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.chart),
          label: 'Chart',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.profile),
          label: 'Profile',
        ),
      ],
    );
  }
}
