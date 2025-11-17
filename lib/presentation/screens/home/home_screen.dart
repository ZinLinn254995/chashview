import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/circular_progress_widget.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/mini_line_chart.dart';
import '../../widgets/money_type_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double progressValue = 1; // 100%
  final List<FlSpot> dataPoints = [
    FlSpot(0, 3.0),
    FlSpot(1, 1.5),
    FlSpot(2, 1.4),
    FlSpot(3, 2.2),
    FlSpot(4, 2.8),
    FlSpot(5, 3.5),
    FlSpot(6, 0.0),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MainViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Background from theme

      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppPadding.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppPadding.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer, // surface variant color
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final progressSize = constraints.maxWidth;
                        return Center(
                          child: CircularProgressWidget(
                            progress: progressValue,
                            size: progressSize,
                          ),
                        );
                      },
                    ),
                  ),
                  AppGap.lg,
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MoneyTypeText(AppStrings.targetBalance),
                        CurrencyText(
                          amount: 1000,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppGap.sm,
                        MoneyTypeText(AppStrings.currentBalance),
                        CurrencyText(
                          amount: 1000,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppGap.sm,

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(AppPadding.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MoneyTypeText(AppStrings.income),
                              CurrencyText(
                                amount: 999,
                                compact: true,
                                useDecimalRatio: true,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppGap.sm,
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 50,
                            height: 20,
                            child: MiniLineChart(
                              dataPoints: dataPoints,
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                AppGap.sm,

                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(AppPadding.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MoneyTypeText(AppStrings.expense),
                              CurrencyText(
                                amount: 1300,
                                compact: true,
                                useDecimalRatio: false,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppGap.sm,
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: 50,
                            height: 20,
                            child: MiniLineChart(
                              dataPoints: dataPoints,
                              color: colorScheme.error,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppGap.sm,

            Container(
              padding: EdgeInsets.all(AppPadding.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              // TODO: Add content here later
            ),
          ],
        ),
      ),
    );
  }
}
