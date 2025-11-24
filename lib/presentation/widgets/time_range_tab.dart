import 'package:flutter/material.dart';

enum TimeRangeTab { daily, monthly, yearly, allTime }

class TimeRangeTabWidget extends StatelessWidget {
  final TimeRangeTab selectedTab;
  final Function(TimeRangeTab) onTabSelected;
  final bool showAllTimeTab; // ✅ NEW: All Time Tab ကို ပြမလား၊ မပြဘူးလား ထိန်းချုပ်ရန်

  const TimeRangeTabWidget({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.showAllTimeTab = true, // Default က true ဖြစ်လို့၊ မထည့်ရင် ၄ ခုလုံး ပေါ်မယ်
  });

  String _label(TimeRangeTab tab) {
    switch (tab) {
      case TimeRangeTab.daily:
        return 'Daily';
      case TimeRangeTab.monthly:
        return 'Monthly';
      case TimeRangeTab.yearly:
        return 'Yearly';
      case TimeRangeTab.allTime:
        return 'All Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. showAllTimeTab value ပေါ်မူတည်ပြီး Tabs စစ်ထုတ်မယ်
    final tabs = TimeRangeTab.values.where((t) {
      if (!showAllTimeTab && t == TimeRangeTab.allTime) {
        return false; // showAllTimeTab: false ဖြစ်ရင် All Time ကို ဖယ်
      }
      return true; // ကျန်တာတွေ (သို့မဟုတ် showAllTimeTab: true ဖြစ်ရင်) အားလုံး ထည့်
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int i = 0; i < tabs.length; i++) ...[
          GestureDetector(
            onTap: () => onTabSelected(tabs[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: tabs[i] == selectedTab
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _label(tabs[i]),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: tabs[i] == selectedTab
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (i != tabs.length - 1) const SizedBox(width: 8),
        ]
      ],
    );
  }
}