import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/summary_viewmodel.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/time_range_tab.dart';

// ဥပမာအတွက် သုံးထားသော ကိန်းသေများ
const String _kScreenTitle = 'Summary';
const double _kAppPaddingMd = 16.0;

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with AutomaticKeepAliveClientMixin {

  // State Variables for Date Logic (သင်၏မူရင်း Code မှ)
  late TimeRangeTab _selectedTab;
  late DateTime _selectedDate;
  late DateTime _selectedMonth;
  late DateTime _selectedYear;
  DateTimeRange? _selectedRange;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSummaryUpdate();
    });
  }

  void _initializeState() {
    final now = DateTime.now();
    _selectedTab = TimeRangeTab.monthly;
    _selectedDate = now;
    _selectedMonth = DateTime(now.year, now.month);
    _selectedYear = DateTime(now.year);
    _selectedRange = null;
  }

  // Settings Button နှိပ်ခြင်းအတွက်
  void _onSettingsPressed() {
    // TODO: Settings Screen သို့ သွားရန် Logic ရေးပါ
    print('Settings pressed!');
  }

  // --- Event Handlers (သင်၏မူရင်း Code မှ) ---
  void _onTabSelected(TimeRangeTab tab) {
    setState(() => _selectedTab = tab);
    _triggerSummaryUpdate();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    _triggerSummaryUpdate();
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() => _selectedMonth = newMonth);
    _triggerSummaryUpdate();
  }

  void _onYearChanged(DateTime newYear) {
    setState(() => _selectedYear = newYear);
    _triggerSummaryUpdate();
  }

  void _onRangeChanged(DateTimeRange? newRange) {
    setState(() => _selectedRange = newRange);
    _triggerSummaryUpdate();
  }

  // --- Data Management Logic (သင်၏မူရင်း Code မှ) ---
  void _triggerSummaryUpdate() {
    // ... Data Fetching Logic ...
    final vm = context.read<SummaryViewModel>();
    final range = _getCurrentDateRange();

    // (SummaryTimeRange, start, end) ဖြင့် View Model ကို update လုပ်ရန်
    vm.subscribeWithRange(
        _mapTabToRange(_selectedTab),
        range.start,
        range.end
    );
  }

  // ... _getCurrentDateRange() and _mapTabToRange() methods (သင်၏မူရင်းအတိုင်း) ...
  // (Note: Readability အတွက် ဒီနေရာမှာ ထပ်မထည့်တော့ပါ။)

  DateTimeRange _getCurrentDateRange() {
    switch (_selectedTab) {
      case TimeRangeTab.daily:
        final start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        final end = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        );
        return DateTimeRange(start: start, end: end);

      case TimeRangeTab.monthly:
        final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        final end = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
          0,
          23,
          59,
          59,
        );
        return DateTimeRange(start: start, end: end);

      case TimeRangeTab.yearly:
        final start = DateTime(_selectedYear.year, 1, 1);
        final end = DateTime(_selectedYear.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);

      case TimeRangeTab.allTime:
        if (_selectedRange == null) {
          // All time default (1900 to Now)
          return DateTimeRange(start: DateTime(1900), end: DateTime.now());
        }
        final end = DateTime(
          _selectedRange!.end.year,
          _selectedRange!.end.month,
          _selectedRange!.end.day,
          23,
          59,
          59,
        );
        return DateTimeRange(start: _selectedRange!.start, end: end);
    }
  }

  SummaryTimeRange _mapTabToRange(TimeRangeTab tab) {
    switch (tab) {
      case TimeRangeTab.daily:
        return SummaryTimeRange.daily;
      case TimeRangeTab.monthly:
        return SummaryTimeRange.monthly;
      case TimeRangeTab.yearly:
        return SummaryTimeRange.yearly;
      case TimeRangeTab.allTime:
        return SummaryTimeRange.allTime;
    }
  }


  // --- Custom App Bar (သင်ပေးပို့သော Code ကို အသုံးပြုခြင်း) ---
  Widget _buildCustomAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      // kToolbarHeight (56.0) + အောက်က Tab Bar အတွက် နေရာ
      height: kToolbarHeight + 50,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: _kAppPaddingMd),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end, // အောက်ခြေကပ်ရန် ပြင်သည်
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _kScreenTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: colorScheme.onSurface,
                onPressed: _onSettingsPressed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // TimeRangeTabWidget သည် `lib/presentation/widgets/time_range_tab.dart` ရှိသည်ဟု ယူဆသည်။
          TimeRangeTabWidget(
            selectedTab: _selectedTab,
            showAllTimeTab: true, // Summary မှာ All Time ကိုပြဖို့ ဖွင့်ပေးလိုက်သည်
            onTabSelected: _onTabSelected,
          ),
          const SizedBox(height: 9),// Tab အောက်နားလေး ခွာရန်
        ],
      ),
    );
  }

  // --- Summary Card Widget (သင်၏မူရင်းအတိုင်း) ---
  Widget _buildSummaryCard(
      BuildContext context, {
        required String title,
        required double amount,
        required IconData icon,
        required Gradient gradient,
        bool isLarge = false,
      }) {
    // ... Card UI Implementation (သင်၏မူရင်းအတိုင်း)
    final theme = Theme.of(context);
    const textColor = Colors.white;

    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: isLarge ? 24 : 20, color: textColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: textColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 20 : 16),
          CurrencyText(
            amount: amount,
            style: isLarge
                ? theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            )
                : theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            useDecimalRatio: true,
          ),
        ],
      ),
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // --- Gradients Definitions (သင်၏မူရင်း Code မှ) ---
    const netGradient = LinearGradient(
      colors: [Color(0xFF6200EA), Color(0xFF2962FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const incomeGradient = LinearGradient(
      colors: [Color(0xFF43A047), Color(0xFF1DE9B6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const expenseGradient = LinearGradient(
      colors: [Color(0xFFFF5F00), Color(0xFFF6B000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );


    return Scaffold(
      // 1. Custom App Bar ကို PreferredSize Widget ဖြင့် အစားထိုးခြင်း
      // PreferredSize က Container ရဲ့ Height ကို Scaffold ကို ပြောပြပေးတယ်။
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 50),
        child: SafeArea(
          bottom: false, // AppBar ကို အပေါ်ဆုံးထိ ဆွဲတင်ရန်
          child: _buildCustomAppBar(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: _kAppPaddingMd), // Body မှာ Padding ပေးသည်။
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Date Picker (ယခင်က Header ထဲတွင်ရှိရာမှ Body အစသို့ ရွှေ့လိုက်သည်။) ---
            //const SizedBox(height: 16),
            Center(
              child: DateRangePicker(
                selectedTab: _selectedTab,
                selectedDate: _selectedDate,
                selectedMonth: _selectedMonth,
                selectedYear: _selectedYear,
                selectedRange: _selectedRange,
                onDateChanged: _onDateChanged,
                onMonthChanged: _onMonthChanged,
                onYearChanged: _onYearChanged,
                onRangeChanged: _onRangeChanged,
              ),
            ),

            const SizedBox(height: 8),

            // --- Summary Cards ---
            Consumer<SummaryViewModel>(
              builder: (context, vm, child) {
                final range = _mapTabToRange(_selectedTab);
                final data = vm.getSummary(range);

                final income = data?.totalIncome ?? 0.0;
                final expense = data?.totalExpense ?? 0.0;
                final net = data?.net ?? 0.0;

                if (vm.isLoading && data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    // Net Balance Card
                    _buildSummaryCard(
                      context,
                      title: 'Net Balance',
                      amount: net,
                      icon: Icons.account_balance_wallet,
                      gradient: netGradient,
                      isLarge: true,
                    ),

                    const SizedBox(height: 16),

                    // Income & Expense Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            title: 'Income',
                            amount: income,
                            icon: Icons.arrow_downward_rounded,
                            gradient: incomeGradient,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            title: 'Expense',
                            amount: expense,
                            icon: Icons.arrow_upward_rounded,
                            gradient: expenseGradient,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}