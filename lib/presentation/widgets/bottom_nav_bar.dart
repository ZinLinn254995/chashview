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

  // တစ်ခါတည်းနဲ့ အိုင်ကွန်နဲ့ label ကို စုစည်းထားတာ ပိုရှင်းလင်းတယ်
  static const List<({IconData icon, String label})> _items = [
    (icon: AppIcons.home,     label: 'Home'),
    (icon: AppIcons.income,   label: 'Income'),
    (icon: AppIcons.expense,  label: 'Expense'),
    (icon: AppIcons.chart,    label: 'Chart'),
    (icon: AppIcons.profile,  label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest, // M3 မှာ surface ထက် အနည်းငယ်မြင့်တဲ့ အရောင်သုံးတာ ပိုလှတယ်
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant,
                width: 0.8, // iOS-style အနည်းငယ်ထူအောင်
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Container က အရောင်ပေးပြီးသားမို့ transparent လုပ်ထား

            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.6),

            selectedFontSize: 12,
            unselectedFontSize: 12,
            showSelectedLabels: true,
            showUnselectedLabels: true,

            // label style ကို theme ထဲက default ကိုပဲ သုံးလို့ရတယ် (လိုအပ်ရင်ပဲ override)
            selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.labelSmall,

            items: _items.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon, size: 24),
              activeIcon: Icon(item.icon, size: 26), // selected ဖြစ်ရင် အနည်းငယ်ကြီးအောင် (M3 recommendation)
              label: item.label,
            )).toList(),
          ),
        ),
      ),
    );
  }
}