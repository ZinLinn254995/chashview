import 'package:flutter/material.dart';

enum TimeRangeTab { daily, monthly, yearly, allTime }

class TimeRangeTabWidget extends StatelessWidget {
  final TimeRangeTab selectedTab;
  final Function(TimeRangeTab) onTabSelected;

  const TimeRangeTabWidget({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
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
    final tabs = TimeRangeTab.values;

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
