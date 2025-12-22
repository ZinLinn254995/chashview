import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Constants & Routes
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';

// Entities
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';

// Widgets
import '../../widgets/currency_text.dart';
import '../../widgets/custom_empty_widget.dart';

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
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      // User ရှိမှသာ data range subscribe လုပ်မည်
      if (authVM.user != null) {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

        summaryVM.subscribeWithRange(SummaryTimeRange.homeDaily, start, end);

        // Note: Category & Title ViewModels init streams automatically in their constructor
        // based on AuthViewModel, so we don't need to manually call fetch here.
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCartPressed() {
    Navigator.pushNamed(context, RouteNames.cart);
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

            // Tab Bar
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

            // TabBarView Content
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
    return Consumer2<AuthViewModel, TitleViewModel>(
      builder: (context, authVM, titleVM, _) {
        final name = authVM.user?.displayName ?? '...';
        final greetingMessage = _getDynamicGreeting();

        // TitleViewModel ရှိ expenseTitles ကို သုံးပြီး Cart Count တွက်ပါ
        final cartCount = titleVM.expenseTitles.where((t) => t.cart).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // --- Cart Icon Section ---
            Badge(
              isLabelVisible: cartCount > 0,
              label: Text(cartCount.toString()),
              offset: const Offset(-4, 0),
              child: IconButton(
                onPressed: _onCartPressed,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning! Ready to track?";
    } else if (hour < 17) {
      return "Good Afternoon! Keep it up.";
    } else if (hour < 21) {
      return "Good Evening! How was your spending?";
    } else {
      return "Good Night! Rest well.";
    }
  }

  // ==================== Summary Card ====================
  Widget _buildDailySummaryCard(BuildContext context) {
    return Consumer<SummaryViewModel>(
      builder: (context, vm, child) {
        final data = vm.getSummary(SummaryTimeRange.homeDaily);

        // 🔥 Loading State: Data မရောက်သေးရင် Skeleton ပြမည်
        if (vm.isLoading || data == null) {
          return const _SkeletonSummaryCard();
        }

        final income = data.totalIncome;
        final expense = data.totalExpense;
        final net = data.net;

        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6200EA),
                Color(0xFF2962FF),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCompactRow(
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF69F0AE),
                    amount: income,
                  ),
                  const SizedBox(height: 8),
                  _buildCompactRow(
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFFF8A80),
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
// Bookmarked Grouped Grid with Synchronized Loading
// =============================================================================
class _BookmarkedGroupedGrid extends StatelessWidget {
  final String type; // 'income' or 'expense'

  const _BookmarkedGroupedGrid({required this.type});

  Future<void> _showAmountDialog(BuildContext context, TitleEntity title) async {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final String transactionType = 'expense'; // expense အတွက်သာ cart logic ထည့်မှာမို့လို့

    DateTime selectedDate = DateTime.now();

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (innerCtx, setState) {
          final bool isExpense = type == transactionType; // ပြန်စစ်ဆေး

          // 💡 EXPENSE အတွက်သာ Add to Cart Button ကို ထည့်သွင်းခြင်း
          final Widget cartButtonRow = isExpense
              ? Builder(
              builder: (context) {
                final titleVM = context.read<TitleViewModel>();
                final bool isInCart = title.cart;

                // 🎯 FilledButton.icon အစား IconButton ကို အသုံးပြုခြင်း
                return IconButton(
                  // ℹ️ tooltip ကို စာသားအစားထိုး အသုံးပြုခြင်း
                  tooltip: isInCart ? "Remove from Cart" : "Add to Cart",
                  icon: Icon(
                    isInCart
                        ? Icons.shopping_cart
                        : Icons.shopping_cart_outlined,
                    // 🎨 Icon ၏အရောင်ကို ပြောင်းလဲခြင်း
                    color: isInCart ? Colors.orange : Colors.orange,
                    size: 24, // 🗜️ Icon အရွယ်အစားကို ချိန်ညှိနိုင်သည်
                  ),
                  onPressed: () {
                    // Cart အခြေအနေကို ပြောင်းလဲခြင်း
                    titleVM.toggleTitleCart(
                      transactionType,
                      title.id,
                      !isInCart,
                    );

                    // 📣 SnackBar ပြသပြီး Dialog ပိတ်ခြင်း
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        backgroundColor: isInCart ? Colors.red : Colors.orange,
                        content: Text(
                          isInCart
                              ? "'${title.name}' removed from cart"
                              : "'${title.name}' added to cart",
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(ctx, null);
                  },
                );
              })
              : const SizedBox.shrink(); // income ဆိုရင် ဘာမှမပြ

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

            // ⚠️ title ကိုသာပြပြီး content ကို Column နဲ့ ပေါင်းလိုက်မယ်
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
                // 🎯 Cart Button Row ကို title အောက်တွင် ထည့်သွင်းခြင်း
                if (isExpense) cartButtonRow,
              ],
            ),

            // 💡 Content အစား Column ကို သုံးပြီး Cart Button, Amount, Date များကို စီစဉ်ခြင်း
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Amount ထည့်သွင်းသည့် နေရာ
                TextField(
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
                const SizedBox(height: 16),

                // 2. Date ရွေးချယ်သည့် နေရာ (Select Date Widget)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: innerCtx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
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
          );
        },
      ),
    );

    // --- ဒေတာ သိမ်းဆည်းခြင်း အပိုင်း (Dialog ပိတ်ပြီးနောက်) ---
    if (amount != null && context.mounted) {
      if (type == 'income') {
        final incomeVM = context.read<IncomeViewModel>();
        final newIncome = IncomeEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: selectedDate,
          createdAt: DateTime.now(),
        );
        await incomeVM.addIncome(newIncome);
      } else {
        final expenseVM = context.read<ExpenseViewModel>();
        final newExpense = ExpenseEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: selectedDate,
          createdAt: DateTime.now(),
        );
        await expenseVM.addExpense(newExpense);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${type == 'income' ? '+' : '-'} ${amount.toStringAsFixed(2)} • ${title.name} (${selectedDate.day}/${selectedDate.month})",
            ),
            backgroundColor: type == 'income' ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CategoryViewModel, TitleViewModel, SummaryViewModel>(
      builder: (context, categoryVM, titleVM, summaryVM, child) {

        // 🔥 KEY FIX IS HERE 🔥

        // ၁. Summary Data ကိုအရင်ဆွဲထုတ်ပါ
        final summaryData = summaryVM.getSummary(SummaryTimeRange.homeDaily);

        // ၂. Loading Condition ကို ပိုတိကျအောင်စစ်ပါ
        // ViewModel တွေ Loading ဖြစ်နေရင် (သို့မဟုတ်) Summary Data က null ဖြစ်နေရင် (မရောက်သေးရင်)
        // Skeleton ကို ပြပါမယ်။ ဒါဆိုရင် Initial State မှာ Empty Widget မပြတော့ပါဘူး။
        final bool isInitializing = summaryData == null;
        final bool isLoading = categoryVM.isLoading || titleVM.isLoading || summaryVM.isLoading;

        if (isLoading || isInitializing) {
          return const _SkeletonGrid();
        }

        // --- Data Loaded Logic Starts Here ---

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

        // Empty State Check (Data တကယ်ရောက်ပြီးမှ စစ်ဆေးခြင်း)
        if (relevantCategories.isEmpty) {
          return Center(
            child: CustomEmptyWidget(
              type: EmptyStateType.section,
              title: "No Shortcuts",
              message: "Bookmark your frequently used ${type}s to see them here.",
              icon: Icons.bookmark_border,
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

  Widget _buildTitleCard(BuildContext context, TitleEntity title) {
    // (Code မပြောင်းလဲပါ - ယခင်အတိုင်းထားပါ)
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 🦴 SKELETON WIDGETS (For Smooth Loading)
// =============================================================================

class _SkeletonSummaryCard extends StatelessWidget {
  const _SkeletonSummaryCard();

  @override
  Widget build(BuildContext context) {
    // မီးခိုးရောင်ဖျော့ဖျော့ background
    final baseColor =
    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlightColor =
    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 80, height: 12, color: highlightColor),
              const SizedBox(height: 10),
              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          // Right side skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                      color: highlightColor,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                      color: highlightColor,
                      borderRadius: BorderRadius.circular(4))),
            ],
          )
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.builder(
      padding: const EdgeInsets.all(AppPadding.md),
      itemCount: 3, // Dummy categories
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Title Skeleton
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Grid Skeleton
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4, // Dummy items
              itemBuilder: (context, i) => Container(
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppPadding.xl),
          ],
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Constants & Routes
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';

// Entities
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';

// Widgets
import '../../widgets/currency_text.dart';
import '../../widgets/custom_empty_widget.dart';

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
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      if (authVM.user != null) {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

        summaryVM.subscribeWithRange(SummaryTimeRange.homeDaily, start, end);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCartPressed() {
    Navigator.pushNamed(context, RouteNames.cart);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
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

  Widget _buildTopHeader(BuildContext context) {
    return Consumer2<AuthViewModel, TitleViewModel>(
      builder: (context, authVM, titleVM, _) {
        final name = authVM.user?.displayName ?? '...';
        final greetingMessage = _getDynamicGreeting();
        final cartCount = titleVM.expenseTitles.where((t) => t.cart).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.3,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Badge(
              isLabelVisible: cartCount > 0,
              label: Text(cartCount.toString()),
              offset: const Offset(-4, 0),
              child: IconButton(
                onPressed: _onCartPressed,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning! Ready to track?";
    if (hour < 17) return "Good Afternoon! Keep it up.";
    if (hour < 21) return "Good Evening! How was your spending?";
    return "Good Night! Rest well.";
  }

  Widget _buildDailySummaryCard(BuildContext context) {
    return Consumer<SummaryViewModel>(
      builder: (context, vm, child) {
        final data = vm.getSummary(SummaryTimeRange.homeDaily);
        if (vm.isLoading || data == null) return const _SkeletonSummaryCard();

        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6200EA), Color(0xFF2962FF)],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Today's Net",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12)),
                  const SizedBox(height: 4),
                  CurrencyText(
                    amount: data.net,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCompactRow(
                      icon: Icons.arrow_downward_rounded,
                      color: const Color(0xFF69F0AE),
                      amount: data.totalIncome),
                  const SizedBox(height: 8),
                  _buildCompactRow(
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFFFF8A80),
                      amount: data.totalExpense),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactRow(
      {required IconData icon, required Color color, required double amount}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        CurrencyText(
            amount: amount,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

class _BookmarkedGroupedGrid extends StatelessWidget {
  final String type;
  const _BookmarkedGroupedGrid({required this.type});

  Future<void> _showAmountDialog(BuildContext context, TitleEntity title) async {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    DateTime selectedDate = DateTime.now();

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (innerCtx, setState) {
          final bool isExpense = type == 'expense';
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  type == 'income' ? Icons.add_circle : Icons.remove_circle,
                  color: type == 'income' ? colorScheme.secondary : colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title.name, style: Theme.of(context).textTheme.titleMedium)),
                if (isExpense)
                  IconButton(
                    icon: Icon(title.cart ? Icons.shopping_cart : Icons.shopping_cart_outlined, color: Colors.orange),
                    onPressed: () {
                      context.read<TitleViewModel>().toggleTitleCart('expense', title.id, !title.cart);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:'),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                            context: innerCtx, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              FilledButton(
                onPressed: () {
                  final val = double.tryParse(controller.text.trim());
                  if (val != null && val > 0) Navigator.pop(ctx, val);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );

    if (amount != null && context.mounted) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      if (type == 'income') {
        await context.read<IncomeViewModel>().addIncome(IncomeEntity(id: id, titleId: title.id, amount: amount, date: selectedDate, createdAt: DateTime.now()));
      } else {
        await context.read<ExpenseViewModel>().addExpense(ExpenseEntity(id: id, titleId: title.id, amount: amount, date: selectedDate, createdAt: DateTime.now()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CategoryViewModel, TitleViewModel, SummaryViewModel>(
      builder: (context, categoryVM, titleVM, summaryVM, child) {
        final summaryData = summaryVM.getSummary(SummaryTimeRange.homeDaily);
        if (categoryVM.isLoading || titleVM.isLoading || summaryData == null) return const _SkeletonGrid();

        final allCategories = categoryVM.getCategoriesByType(type);
        final allTitles = titleVM.getTitlesByType(type);
        final relevantCategories = allCategories.where((cat) => allTitles.any((t) => t.categoryId == cat.id && t.bookmark)).toList();

        if (relevantCategories.isEmpty) {
          return Center(child: CustomEmptyWidget(type: EmptyStateType.section, title: "No Shortcuts", message: "Bookmark items to see them here.", icon: Icons.bookmark_border));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppPadding.md),
          itemCount: relevantCategories.length,
          itemBuilder: (context, index) {
            final category = relevantCategories[index];
            final titles = allTitles.where((t) => t.categoryId == category.id && t.bookmark).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(category.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ),
                // 💡 ပြင်ဆင်ထားသော Wrap အပိုင်း
                Wrap(
                  spacing: 10, // Item များကြား အလျားလိုက်ခြားနားချက်
                  runSpacing: 10, // Item များကြား အပေါ်အောက်ခြားနားချက်
                  children: titles.map((title) => _buildTitleCard(context, title)).toList(),
                ),
                const SizedBox(height: AppPadding.xl),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTitleCard(BuildContext context, TitleEntity title) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showAmountDialog(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 💡 စာသားအရှည်အတိုင်းဖြစ်စေရန်
          children: [
            Icon(Icons.star_rounded, size: 18, color: type == 'income' ? colorScheme.secondary : colorScheme.tertiary),
            const SizedBox(width: 8),
            Text(title.name, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// Skeleton Widgets (ထိန်းသိမ်းထားပါသည်)
class _SkeletonSummaryCard extends StatelessWidget {
  const _SkeletonSummaryCard();
  @override
  Widget build(BuildContext context) {
    return Container(height: 100, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)));
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}*/
