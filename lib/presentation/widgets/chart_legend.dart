import 'package:flutter/material.dart';

// Type ခွဲရန် Enum ဖန်တီးပါသည် (သို့မဟုတ် သင့် project ရှိ existing enum ကိုသုံးပါ)
enum Type { income, expense }

class ChartLegend extends StatelessWidget {
  final bool isAllTime;
  final Type type; // 🔥 Type ထည့်သွင်းခြင်း
  final String currentPeriodName;
  final String previousPeriodName;

  const ChartLegend({
    super.key,
    required this.isAllTime,
    required this.type, // 🔥 Required လုပ်ထားပါသည်
    this.currentPeriodName = "Current",
    this.previousPeriodName = "Previous",
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: 11,
    );

    // 🔥 Color Logic
    // Income ဖြစ်ပါက Primary, Expense ဖြစ်ပါက Error ကိုသုံးပါမည်
    final Color mainColor = type == Type.income
        ? colorScheme.secondary
        : colorScheme.tertiary;

    // Secondary Color (Comparison)
    Color secondaryColor;
    if (isAllTime) {
      // All Time မှာ Income vs Expense ယှဉ်မယ်ဆိုရင် ဆန့်ကျင်ဘက်အရောင်ယူမယ်
      secondaryColor = type == Type.income
          ? colorScheme.primary // Income chart မှာ Expense က အနီဖျော့
          : colorScheme.primary; // Expense chart မှာ Income က အစိမ်းဖျော့
    } else {
      // Period ယှဉ်တာဆိုရင် (ဥပမာ ဒီလ vs ပြီးခဲ့တဲ့လ) မီးခိုးရောင်/Secondary ပဲထားမယ်
      secondaryColor = colorScheme.primary;
    }

    // 🔥 Label Logic
    String label1;
    String label2;

    if (isAllTime) {
      // All Time ဆိုရင် Type အလိုက် စာသားပြောင်းမယ်
      label1 = type == Type.income ? "Total Income" : "Total Expense";
      label2 = type == Type.income ? "Total Expense" : "Total Income";
    } else {
      label1 = currentPeriodName;
      label2 = previousPeriodName;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(mainColor, label1, textStyle),
        const SizedBox(height: 4),
        _buildLegendItem(secondaryColor, label2, textStyle),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, TextStyle? style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}