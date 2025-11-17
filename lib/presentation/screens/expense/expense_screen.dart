import 'package:flutter/material.dart';

import '../../../core/constants/app_colors_dark.dart';
import '../../../core/constants/app_colors_light.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 3 Colors Demo'),
        backgroundColor: AppColorsLight.primary,
        foregroundColor: AppColorsLight.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Primary Colors'),
            _buildColorRow('Primary', AppColorsLight.primary, AppColorsLight.onPrimary),
            _buildColorRow('Primary Container', AppColorsLight.primaryContainer, AppColorsLight.onPrimaryContainer),

            _buildSectionTitle('Secondary Colors'),
            _buildColorRow('Secondary', AppColorsLight.secondary, AppColorsLight.onSecondary),
            _buildColorRow('Secondary Container', AppColorsLight.secondaryContainer, AppColorsLight.onSecondaryContainer),

            _buildSectionTitle('Tertiary Colors'),
            _buildColorRow('Tertiary', AppColorsLight.tertiary, AppColorsLight.onTertiary),
            _buildColorRow('Tertiary Container', AppColorsLight.tertiaryContainer, AppColorsLight.onTertiaryContainer),

            _buildSectionTitle('Error Colors'),
            _buildColorRow('Error', AppColorsLight.error, AppColorsLight.onError),
            _buildColorRow('Error Container', AppColorsLight.errorContainer, AppColorsLight.onErrorContainer),

            _buildSectionTitle('Surface Colors'),
            _buildColorRow('Surface', AppColorsLight.surface, AppColorsLight.onSurface),
            _buildColorRow('Surface Container Lowest', AppColorsLight.surfaceContainerLowest, AppColorsLight.onSurface),
            _buildColorRow('Surface Container Low', AppColorsLight.surfaceContainerLow, AppColorsLight.onSurface),
            _buildColorRow('Surface Container', AppColorsLight.surfaceContainer, AppColorsLight.onSurface),
            _buildColorRow('Surface Container High', AppColorsLight.surfaceContainerHigh, AppColorsLight.onSurface),
            _buildColorRow('Surface Container Highest', AppColorsLight.surfaceContainerHighest, AppColorsLight.onSurface),

            _buildSectionTitle('Surface Variants'),
            _buildColorRow('On Surface Variant', AppColorsLight.surface, AppColorsLight.onSurfaceVariant),
            _buildColorRow('Outline Variant', AppColorsLight.outlineVariant, AppColorsLight.onSurface),
            _buildColorRow('Outline', AppColorsLight.outline, AppColorsLight.surface),

            _buildSectionTitle('Interactive Components'),
            _buildInteractiveComponents(),

            _buildSectionTitle('Cards with Surface Containers'),
            _buildCardExamples(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColorsLight.primary,
        foregroundColor: AppColorsLight.onPrimary,
        child: const Icon(Icons.add),
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

  Widget _buildColorRow(String label, Color backgroundColor, Color textColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsLight.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInteractiveComponents() {
    return Column(
      children: [
        // Buttons
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
              child: const Text('Elevated Button'),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColorsLight.secondary,
                foregroundColor: AppColorsLight.onSecondary,
              ),
              child: const Text('Filled Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColorsLight.primary,
                side: BorderSide(color: AppColorsLight.primary),
              ),
              child: const Text('Outlined Button'),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColorsLight.tertiary,
              ),
              child: const Text('Text Button'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Chips
        Wrap(
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
          ],
        ),

        const SizedBox(height: 16),

        // Progress Indicator
        LinearProgressIndicator(
          value: 0.7,
          backgroundColor: AppColorsLight.surfaceContainer,
          color: AppColorsLight.primary,
        ),
      ],
    );
  }

  Widget _buildCardExamples() {
    return Column(
      children: [
        Card(
          color: AppColorsLight.surfaceContainerLowest,
          child: const ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Surface Container Lowest'),
            subtitle: Text('This card uses surfaceContainerLowest'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColorsLight.surfaceContainerLow,
          child: const ListTile(
            leading: Icon(Icons.savings),
            title: Text('Surface Container Low'),
            subtitle: Text('This card uses surfaceContainerLow'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColorsLight.surfaceContainer,
          child: const ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Surface Container'),
            subtitle: Text('This card uses surfaceContainer'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColorsLight.surfaceContainerHigh,
          child: const ListTile(
            leading: Icon(Icons.trending_up),
            title: Text('Surface Container High'),
            subtitle: Text('This card uses surfaceContainerHigh'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColorsLight.surfaceContainerHighest,
          child: const ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Surface Container Highest'),
            subtitle: Text('This card uses surfaceContainerHighest'),
          ),
        ),
      ],
    );
  }
}