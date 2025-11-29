import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<({IconData icon, String label})> _items = [
    (icon: AppIcons.home,     label: 'Home'),
    (icon: AppIcons.income,   label: 'Income'),
    (icon: AppIcons.expense,  label: 'Expense'),
    (icon: AppIcons.chart,    label: 'Chart'),
    (icon:  Icons.trending_up,  label: 'Summary'),
    (icon: AppIcons.profile,  label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant,
                width: 0.8,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,

            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),

            selectedFontSize: 12,
            unselectedFontSize: 12,
            showSelectedLabels: true,
            showUnselectedLabels: true,


            selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.labelSmall,

            items: _items.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon, size: 24),
              activeIcon: Icon(item.icon, size: 26),
              label: item.label,
            )).toList(),
          ),
        ),
      ),
    );
  }
}