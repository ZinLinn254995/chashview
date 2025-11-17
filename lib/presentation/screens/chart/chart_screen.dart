import 'package:flutter/material.dart';
import '../../../core/constants/app_colors_light.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreen();
}

class _ChartScreen extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSwitchOn = true;
  bool _isCheckboxChecked = true;
  double _sliderValue = 0.7;
  int _selectedRadioValue = 1;
  int _selectedSegment = 0;
  RangeValues _rangeValues = const RangeValues(0.2, 0.8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Material 3 Widgets Demo'),
          backgroundColor: AppColorsLight.primary,
          foregroundColor: AppColorsLight.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              color: AppColorsLight.onPrimary,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
              color: AppColorsLight.onPrimary,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColorsLight.onPrimary,
            labelColor: AppColorsLight.onPrimary,
            unselectedLabelColor: AppColorsLight.onPrimary.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Basic'),
              Tab(text: 'Input'),
              Tab(text: 'Layout'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicWidgetsTab(),
            _buildInputWidgetsTab(),
            _buildLayoutWidgetsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColorsLight.primary,
          foregroundColor: AppColorsLight.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBasicWidgetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Cards'),
          _buildCardExamples(),

          _buildSectionTitle('Chips'),
          _buildChipExamples(),

          _buildSectionTitle('Progress Indicators'),
          _buildProgressIndicators(),

          _buildSectionTitle('Navigation'),
          _buildNavigationRail(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputWidgetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Buttons'),
          _buildButtonExamples(),

          _buildSectionTitle('Selection Controls'),
          _buildSelectionControls(),

          _buildSectionTitle('Sliders'),
          _buildSliderExamples(),

          _buildSectionTitle('Text Fields'),
          _buildTextFieldExamples(),

          _buildSectionTitle('Segmented Button'),
          _buildSegmentedButton(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLayoutWidgetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('List Tiles'),
          _buildListTileExamples(),

          _buildSectionTitle('Dialogs'),
          _buildDialogExample(),

          _buildSectionTitle('App Bars'),
          _buildAppBarVariants(),

          _buildSectionTitle('Containers'),
          _buildContainerExamples(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColorsLight.primary,
        ),
      ),
    );
  }

  Widget _buildCardExamples() {
    return Column(
      children: [
        Card(
          color: AppColorsLight.surfaceContainerLowest,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColorsLight.primaryContainer,
              child: Icon(Icons.account_balance_wallet, color: AppColorsLight.onPrimaryContainer),
            ),
            title: Text('Primary Card', style: TextStyle(color: AppColorsLight.onSurface)),
            subtitle: Text('Uses surfaceContainerLowest', style: TextStyle(color: AppColorsLight.onSurfaceVariant)),
            trailing: Icon(Icons.chevron_right, color: AppColorsLight.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColorsLight.surfaceContainer,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColorsLight.secondaryContainer,
              child: Icon(Icons.savings, color: AppColorsLight.onSecondaryContainer),
            ),
            title: Text('Secondary Card', style: TextStyle(color: AppColorsLight.onSurface)),
            subtitle: Text('Uses surfaceContainer', style: TextStyle(color: AppColorsLight.onSurfaceVariant)),
            trailing: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColorsLight.primary,
                foregroundColor: AppColorsLight.onPrimary,
              ),
              child: const Text('Action'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColorsLight.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColorsLight.primary),
                    const SizedBox(width: 8),
                    Text('Financial Overview', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorsLight.onSurface,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: AppColorsLight.surfaceContainerLow,
                  color: AppColorsLight.primary,
                ),
                const SizedBox(height: 8),
                Text('75% of budget used', style: TextStyle(
                  color: AppColorsLight.onSurfaceVariant,
                  fontSize: 12,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipExamples() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InputChip(
          label: const Text('Input Chip'),
          onPressed: () {},
          backgroundColor: AppColorsLight.surfaceContainerLow,
        ),
        FilterChip(
          label: const Text('Filter Chip'),
          selected: true,
          onSelected: (bool value) {},
          selectedColor: AppColorsLight.primaryContainer,
          checkmarkColor: AppColorsLight.onPrimaryContainer,
        ),
        ActionChip(
          label: const Text('Action Chip'),
          onPressed: () {},
          backgroundColor: AppColorsLight.secondaryContainer,
        ),
        Chip(
          label: const Text('Basic Chip'),
          backgroundColor: AppColorsLight.tertiaryContainer,
          deleteIcon: Icon(Icons.close, color: AppColorsLight.onTertiaryContainer),
          onDeleted: () {},
        ),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: 0.7,
          backgroundColor: AppColorsLight.surfaceContainer,
          color: AppColorsLight.primary,
        ),
        const SizedBox(height: 16),
        CircularProgressIndicator(
          value: 0.7,
          backgroundColor: AppColorsLight.surfaceContainer,
          color: AppColorsLight.primary,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          backgroundColor: AppColorsLight.surfaceContainerLow,
          color: AppColorsLight.secondary,
        ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColorsLight.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.transparent,
            selectedIndex: 0,
            onDestinationSelected: (int index) {},
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Business'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                label: Text('School'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonExamples() {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsLight.primary,
                foregroundColor: AppColorsLight.onPrimary,
              ),
              child: const Text('Elevated'),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColorsLight.secondary,
                foregroundColor: AppColorsLight.onSecondary,
              ),
              child: const Text('Filled'),
            ),
            FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColorsLight.tertiaryContainer,
                foregroundColor: AppColorsLight.onTertiaryContainer,
              ),
              child: const Text('Tonal'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColorsLight.primary,
                side: BorderSide(color: AppColorsLight.primary),
              ),
              child: const Text('Outlined'),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColorsLight.tertiary,
              ),
              child: const Text('Text'),
            ),
            IconButton(
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: AppColorsLight.primaryContainer,
                foregroundColor: AppColorsLight.onPrimaryContainer,
              ),
              icon: const Icon(Icons.favorite),
            ),
            FloatingActionButton.small(
              onPressed: () {},
              backgroundColor: AppColorsLight.secondary,
              foregroundColor: AppColorsLight.onSecondary,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: AppColorsLight.primary,
            foregroundColor: AppColorsLight.onPrimary,
          ),
          icon: const Icon(Icons.download),
          label: const Text('Download Report'),
        ),
      ],
    );
  }

  Widget _buildSelectionControls() {
    return Column(
      children: [
        Row(
          children: [
            Switch(
              value: _isSwitchOn,
              onChanged: (bool value) {
                setState(() {
                  _isSwitchOn = value;
                });
              },
              activeColor: AppColorsLight.primary,
              activeTrackColor: AppColorsLight.primaryContainer,
            ),
            Text('Switch', style: TextStyle(color: AppColorsLight.onSurface)),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: _isCheckboxChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isCheckboxChecked = value!;
                });
              },
              activeColor: AppColorsLight.primary,
              checkColor: AppColorsLight.onPrimary,
            ),
            Text('Checkbox', style: TextStyle(color: AppColorsLight.onSurface)),
          ],
        ),
        Row(
          children: [
            Radio<int>(
              value: 1,
              groupValue: _selectedRadioValue,
              onChanged: (int? value) {
                setState(() {
                  _selectedRadioValue = value!;
                });
              },
              activeColor: AppColorsLight.primary,
            ),
            Text('Option 1', style: TextStyle(color: AppColorsLight.onSurface)),
            const SizedBox(width: 20),
            Radio<int>(
              value: 2,
              groupValue: _selectedRadioValue,
              onChanged: (int? value) {
                setState(() {
                  _selectedRadioValue = value!;
                });
              },
              activeColor: AppColorsLight.primary,
            ),
            Text('Option 2', style: TextStyle(color: AppColorsLight.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderExamples() {
    return Column(
      children: [
        Slider(
          value: _sliderValue,
          onChanged: (double value) {
            setState(() {
              _sliderValue = value;
            });
          },
          activeColor: AppColorsLight.primary,
          inactiveColor: AppColorsLight.surfaceContainer,
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _rangeValues,
          onChanged: (RangeValues values) {
            setState(() {
              _rangeValues = values;
            });
          },
          activeColor: AppColorsLight.primary,
          inactiveColor: AppColorsLight.surfaceContainerLow,
        ),
      ],
    );
  }

  Widget _buildTextFieldExamples() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Outlined Text Field',
            labelStyle: TextStyle(color: AppColorsLight.primary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColorsLight.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColorsLight.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Filled Text Field',
            labelStyle: TextStyle(color: AppColorsLight.primary),
            filled: true,
            fillColor: AppColorsLight.surfaceContainerLow,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'With prefix icon',
            prefixIcon: Icon(Icons.search, color: AppColorsLight.onSurfaceVariant),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColorsLight.outline),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedButton() {
    return SegmentedButton<int>(
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Text('Day'),
          icon: Icon(Icons.calendar_today),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('Week'),
          icon: Icon(Icons.calendar_view_week),
        ),
        ButtonSegment<int>(
          value: 2,
          label: Text('Month'),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: <int>{_selectedSegment},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _selectedSegment = newSelection.first;
        });
      },
    );
  }

  Widget _buildListTileExamples() {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColorsLight.primaryContainer,
            child: Text('A', style: TextStyle(color: AppColorsLight.onPrimaryContainer)),
          ),
          title: Text('List Tile with Avatar', style: TextStyle(color: AppColorsLight.onSurface)),
          subtitle: Text('Secondary text', style: TextStyle(color: AppColorsLight.onSurfaceVariant)),
          trailing: Icon(Icons.chevron_right, color: AppColorsLight.onSurfaceVariant),
          tileColor: AppColorsLight.surfaceContainerLowest,
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.notifications, color: AppColorsLight.primary),
          title: Text('With Icon', style: TextStyle(color: AppColorsLight.onSurface)),
          subtitle: Text('This list tile has an icon', style: TextStyle(color: AppColorsLight.onSurfaceVariant)),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {},
            activeColor: AppColorsLight.primary,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.error, color: AppColorsLight.error),
          title: Text('Error State', style: TextStyle(color: AppColorsLight.onSurface)),
          subtitle: Text('This shows an error state', style: TextStyle(color: AppColorsLight.error)),
          tileColor: AppColorsLight.errorContainer,
        ),
      ],
    );
  }

  Widget _buildDialogExample() {
    return FilledButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColorsLight.surface,
              surfaceTintColor: AppColorsLight.surfaceContainer,
              title: Text('Dialog Title', style: TextStyle(color: AppColorsLight.onSurface)),
              content: Text('This is a Material 3 dialog with proper color scheme.',
                  style: TextStyle(color: AppColorsLight.onSurfaceVariant)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: AppColorsLight.primary)),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorsLight.primary,
                    foregroundColor: AppColorsLight.onPrimary,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColorsLight.primary,
        foregroundColor: AppColorsLight.onPrimary,
      ),
      child: const Text('Show Dialog'),
    );
  }

  Widget _buildAppBarVariants() {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColorsLight.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('Small App Bar Variant',
                style: TextStyle(color: AppColorsLight.onSurface, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColorsLight.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('Large App Bar Variant',
                style: TextStyle(color: AppColorsLight.onPrimaryContainer, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerExamples() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColorsLight.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.star, color: AppColorsLight.onPrimary),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColorsLight.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.attach_money, color: AppColorsLight.onSecondaryContainer),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColorsLight.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColorsLight.outline),
          ),
          child: Icon(Icons.trending_up, color: AppColorsLight.onTertiaryContainer),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorsLight.primary,
                AppColorsLight.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.gradient, color: AppColorsLight.onPrimary),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: AppColorsLight.surfaceContainerLowest,
      selectedItemColor: AppColorsLight.primary,
      unselectedItemColor: AppColorsLight.onSurfaceVariant,
      currentIndex: 0,
      onTap: (int index) {},
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'School',
        ),
      ],
    );
  }
}