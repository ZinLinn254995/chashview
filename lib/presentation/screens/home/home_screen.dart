import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/currency_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
      // Only subscribe to Daily as requested
      summaryVM.subscribe(SummaryTimeRange.daily);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSettingsPressed() {
    Navigator.pushNamed(context, RouteNames.settings);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        // Main layout is a Column (No SingleChildScrollView)
        child: Column(
          children: [
            // 1. Header & Daily Summary (Fixed)
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

            // 2. Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  icon: Icon(Icons.arrow_downward_rounded),
                  text: "Income Shortcuts",
                ),
                Tab(
                  icon: Icon(Icons.arrow_upward_rounded),
                  text: "Expense Shortcuts",
                ),
              ],
            ),

            // 3. Swipeable Tab View (Takes remaining space)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Income Bookmarks
                  _BookmarkedGroupedGrid(type: 'income'),
                  // Tab 2: Expense Bookmarks
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
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final name = authVM.user?.displayName ?? 'User';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $name",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Let's manage your day!",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            IconButton(
              onPressed: _onSettingsPressed,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailySummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SummaryViewModel>(
      builder: (context, vm, child) {
        final data = vm.getSummary(SummaryTimeRange.daily);
        final income = data?.totalIncome ?? 0.0;
        final expense = data?.totalExpense ?? 0.0;
        final net = data?.net ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(AppPadding.md),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.today, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "TODAY'S OVERVIEW",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.md),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(context, "Income", income, Colors.green),
                  Container(width: 1, height: 30, color: colorScheme.outlineVariant),
                  _buildSummaryItem(context, "Expense", expense, Colors.red),
                  Container(width: 1, height: 30, color: colorScheme.outlineVariant),
                  _buildSummaryItem(context, "Net", net, colorScheme.onPrimaryContainer),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        CurrencyText(
          amount: amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widget: Groups Bookmarked Titles by Category in a Grid
// -----------------------------------------------------------------------------
class _BookmarkedGroupedGrid extends StatelessWidget {
  final String type; // 'income' or 'expense'

  const _BookmarkedGroupedGrid({required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryViewModel, TitleViewModel>(
      builder: (context, categoryVM, titleVM, child) {
        // 1. Get Lists based on type
        final allCategories = categoryVM.getCategoriesByType(type);
        final allTitles = titleVM.getTitlesByType(type);

        // 2. Filter: Only get categories that have at least one bookmarked title
        final relevantCategories = <CategoryEntity>[];
        final titlesByCategory = <String, List<TitleEntity>>{};

        for (var category in allCategories) {
          // Find bookmarked titles for this category
          final bookmarkedTitles = allTitles.where((t) =>
          t.categoryId == category.id && t.bookmark
          ).toList();

          if (bookmarkedTitles.isNotEmpty) {
            relevantCategories.add(category);
            titlesByCategory[category.id] = bookmarkedTitles;
          }
        }

        if (relevantCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 48, color: Theme.of(context).disabledColor),
                const SizedBox(height: 8),
                Text("No bookmarked ${type}s yet"),
              ],
            ),
          );
        }

        // 3. Build List of Categories -> Grids
        return ListView.builder(
          padding: const EdgeInsets.all(AppPadding.md),
          itemCount: relevantCategories.length,
          itemBuilder: (context, index) {
            final category = relevantCategories[index];
            final titles = titlesByCategory[category.id]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                // Grid of Titles
                GridView.builder(
                  shrinkWrap: true, // Vital: Allows Grid inside ListView
                  physics: const NeverScrollableScrollPhysics(), // Scroll via parent ListView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 Columns
                    childAspectRatio: 2.5, // Width / Height ratio
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: titles.length,
                  itemBuilder: (context, titleIndex) {
                    final title = titles[titleIndex];
                    return _buildTitleCard(context, title);
                  },
                ),
                const SizedBox(height: AppPadding.lg),
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
      onTap: () {
        // TODO: Handle tap (e.g., Quick Add transaction)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selected: ${title.name}")),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 16,
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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