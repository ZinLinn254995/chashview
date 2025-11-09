import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.backgroundPrimary,
      selectedItemColor: AppColors.neonLime,
      unselectedItemColor: AppColors.white,
      type: BottomNavigationBarType.fixed,
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
