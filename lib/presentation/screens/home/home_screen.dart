import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart'; // Cart ViewModel ထည့်ပါ
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/currency_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scheduleInitialLoad();
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final summaryVM = Provider.of<SummaryViewModel>(context, listen: false);
      summaryVM.subscribe(SummaryTimeRange.daily);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCartPressed() {
    Navigator.pushNamed(context, RouteNames.cart); // Cart Screen ကိုသွားမယ်
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header + Daily Summary
            Padding(
              padding: const EdgeInsets.all(AppPadding.md),
              child: Column(
                children: [
                  _buildTopHeader(context),
                  const SizedBox(height: AppPadding.md),
                  _buildDailySummaryCard(context),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              isScrollable: false,
              tabs: const [
                Tab(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward_rounded, size: 20),
                      SizedBox(width: 8),
                      Text("Income Shortcuts", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                Tab(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward_rounded, size: 20),
                      SizedBox(width: 8),
                      Text("Expense Shortcuts", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _BookmarkedGroupedGrid(type: 'income'),
                  _BookmarkedGroupedGrid(type: 'expense'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Header ====================
  Widget _buildTopHeader(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final name = authVM.user?.displayName ?? 'User';

        // Dynamic Greeting Message ရယူခြင်း
        final String greetingMessage = _getDynamicGreeting();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // စာသားရှည်ရင် အောက်မကျအောင် Expanded သုံးပါတယ်
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $name",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    greetingMessage,
                    key: ValueKey<String>(greetingMessage),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.3,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // --- Cart Icon Section ---
            Consumer<CartViewModel>(
              builder: (context, cartVM, child) {
                final cartCount = cartVM.cartItems.length;
                return Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text(cartCount.toString()),
                  offset: const Offset(-4, 0),
                  child: IconButton(
                    onPressed: _onCartPressed,
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper Logic Function ---
  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;

    String timeGreeting;
    if (hour < 12) {
      timeGreeting = "Good Morning! Ready to track?";
    } else if (hour < 17) {
      timeGreeting = "Good Afternoon! Keep it up.";
    } else if (hour < 21) {
      timeGreeting = "Good Evening! How was your spending?";
    } else {
      timeGreeting = "Good Night! Rest well.";
    }

    return timeGreeting;
  }

  Widget _buildDailySummaryCard(BuildContext context) {
    return Consumer<SummaryViewModel>(
      builder: (context, vm, child) {
        final data = vm.getSummary(SummaryTimeRange.daily);
        final income = data?.totalIncome ?? 0.0;
        final expense = data?.totalExpense ?? 0.0;
        final net = data?.net ?? 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          // Compact padding
          decoration: BoxDecoration(
            // Purple to Blue Gradient
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6200EA), // Deep Purple Accent
                Color(0xFF2962FF), // Blue Accent
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2962FF).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Left Side: Net Amount (Major Focus) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Keep it compact
                children: [
                  Text(
                    "Today's Net",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CurrencyText(
                    amount: net,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22, // Large font for visibility
                    ),
                  ),
                ],
              ),

              // --- Right Side: Income & Expense (Stacked) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Income Row
                  _buildCompactRow(
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF69F0AE), // Bright Green
                    amount: income,
                  ),
                  const SizedBox(height: 8), // Gap between income and expense
                  // Expense Row
                  _buildCompactRow(
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFFF8A80), // Bright Red
                    amount: expense,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper for Right Side Rows
  Widget _buildCompactRow({
    required IconData icon,
    required Color color,
    required double amount,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        CurrencyText(
          amount: amount,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Bookmarked Titles Grid (Income & Expense)
// =============================================================================
class _BookmarkedGroupedGrid extends StatelessWidget {
  final String type; // 'income' or 'expense'

  const _BookmarkedGroupedGrid({required this.type});

  // ==================== Amount Dialog ====================
  Future<void> _showAmountDialog(
    BuildContext context,
    TitleEntity title,
  ) async {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              type == 'income' ? Icons.add_circle : Icons.remove_circle,
              color: type == 'income'
                  ? colorScheme.secondary
                  : colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Amount",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              final value = double.tryParse(text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    // Dialog ကနေ amount ရရင် သက်ဆိုင်ရာ ViewModel ကို ခေါ်ပြီး save လုပ်
    if (amount != null && context.mounted) {
      if (type == 'income') {
        final incomeVM = context.read<IncomeViewModel>();
        final newIncome = IncomeEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await incomeVM.addIncome(newIncome);
      } else {
        final expenseVM = context.read<ExpenseViewModel>();
        final newExpense = ExpenseEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await expenseVM.addExpense(newExpense);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${type == 'income' ? '+' : '-'} ${amount.toStringAsFixed(2)} • ${title.name}",
            ),
            backgroundColor: type == 'income' ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryViewModel, TitleViewModel>(
      builder: (context, categoryVM, titleVM, child) {
        final allCategories = categoryVM.getCategoriesByType(type);
        final allTitles = titleVM.getTitlesByType(type);

        final relevantCategories = <CategoryEntity>[];
        final titlesByCategory = <String, List<TitleEntity>>{};

        for (var cat in allCategories) {
          final bookmarked = allTitles
              .where((t) => t.categoryId == cat.id && t.bookmark)
              .toList();
          if (bookmarked.isNotEmpty) {
            relevantCategories.add(cat);
            titlesByCategory[cat.id] = bookmarked;
          }
        }

        if (relevantCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 56,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  "No bookmarked ${type}s yet",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppPadding.md),
          itemCount: relevantCategories.length,
          itemBuilder: (context, index) {
            final category = relevantCategories[index];
            final titles = titlesByCategory[category.id]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: titles.length,
                  itemBuilder: (context, i) =>
                      _buildTitleCard(context, titles[i]),
                ),
                const SizedBox(height: AppPadding.xl),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== Title Card ====================
  Widget _buildTitleCard(BuildContext context, TitleEntity title) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showAmountDialog(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 18,
              color: type == 'income'
                  ? colorScheme.secondary
                  : colorScheme.tertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
