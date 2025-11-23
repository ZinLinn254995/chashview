import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(textTheme, colorScheme),

              AppGap.lg,

              // Color Palette Section
              _buildColorPaletteSection(colorScheme),

              AppGap.lg,

              // Typography Section
              _buildTypographySection(textTheme),

              AppGap.lg,

              // Buttons Section
              _buildButtonsSection(colorScheme, textTheme),

              AppGap.lg,

              // Input Fields Section
              _buildInputFieldsSection(colorScheme, textTheme),

              AppGap.lg,

              // Cards Section
              _buildCardsSection(colorScheme, textTheme),

              AppGap.lg,

              // Chips Section
              _buildChipsSection(colorScheme, textTheme),

              AppGap.lg,

              // Progress Indicators
              _buildProgressIndicators(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  //              HEADER SECTION
  // ================================================================
  Widget _buildHeaderSection(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Design System',
          style: textTheme.headlineLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: AppFontWeight.bold,
          ),
        ),
         AppGap.sm,
        Text(
          'Material 3 Design Guidelines',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Divider(height: AppPadding.xl),
      ],
    );
  }

  // ================================================================
  //              COLOR PALETTE SECTION
  // ================================================================
  Widget _buildColorPaletteSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette',
        ),
         AppGap.md,
        Wrap(
          spacing: AppPadding.sm,
          runSpacing: AppPadding.sm,
          children: [
            _buildColorChip(
                'Primary', colorScheme.primary, colorScheme.onPrimary),
            _buildColorChip(
                'Secondary', colorScheme.secondary, colorScheme.onSecondary),
            _buildColorChip(
                'Tertiary', colorScheme.tertiary, colorScheme.onTertiary),
            _buildColorChip(
                'Surface', colorScheme.surface, colorScheme.onSurface),
            _buildColorChip('Error', colorScheme.error, colorScheme.onError),
            _buildColorChip('Primary Container', colorScheme.primaryContainer,
                colorScheme.onPrimaryContainer),
            _buildColorChip('Surface Variant', colorScheme.surfaceVariant,
                colorScheme.onSurfaceVariant),
          ],
        ),
      ],
    );
  }

  Widget _buildColorChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.sm, vertical: AppPadding.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: AppFontSize.sm,
          fontWeight: AppFontWeight.medium,
        ),
      ),
    );
  }

  // ================================================================
  //              TYPOGRAPHY SECTION
  // ================================================================
  Widget _buildTypographySection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: textTheme.headlineSmall,
        ),
         AppGap.md,
        _buildTextExample('Headline Large', textTheme.headlineLarge),
        _buildTextExample('Headline Medium', textTheme.headlineMedium),
        _buildTextExample('Headline Small', textTheme.headlineSmall),
        _buildTextExample('Title Large', textTheme.titleLarge),
        _buildTextExample('Title Medium', textTheme.titleMedium),
        _buildTextExample('Title Small', textTheme.titleSmall),
        _buildTextExample('Body Large', textTheme.bodyLarge),
        _buildTextExample('Body Medium', textTheme.bodyMedium),
        _buildTextExample('Body Small', textTheme.bodySmall),
        _buildTextExample('Label Large', textTheme.labelLarge),
        _buildTextExample('Label Medium', textTheme.labelMedium),
        _buildTextExample('Label Small', textTheme.labelSmall),
      ],
    );
  }

  Widget _buildTextExample(String label, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.xs),
      child: Text(label, style: style),
    );
  }

  // ================================================================
  //              BUTTONS SECTION
  // ================================================================
  Widget _buildButtonsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buttons',
          style: textTheme.headlineSmall,
        ),
         AppGap.md,
        Wrap(
          spacing: AppPadding.sm,
          runSpacing: AppPadding.sm,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated'),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('Filled'),
            ),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Tonal'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Text'),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite, size: AppIconSize.md),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
         AppGap.sm,
        Wrap(
          spacing: AppPadding.sm,
          runSpacing: AppPadding.sm,
          children: [
            ElevatedButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
            FilledButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
            OutlinedButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  //              INPUT FIELDS SECTION
  // ================================================================
  Widget _buildInputFieldsSection(ColorScheme colorScheme,
      TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Fields',
          style: textTheme.headlineSmall,
        ),
         AppGap.md,
        TextField(
          decoration: InputDecoration(
            labelText: 'Filled Input',
            hintText: 'Enter your text',
            prefixIcon: Icon(Icons.person, size: AppIconSize.md),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
          ),
        ),
         AppGap.md,
        TextField(
          decoration: InputDecoration(
            labelText: 'Outlined Input',
            hintText: 'Enter your text',
            prefixIcon: Icon(Icons.search, size: AppIconSize.md),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.outline),
              borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.sm)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary),
              borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.sm)),
            ),
          ),
        ),
         AppGap.md,
        TextField(
          decoration: InputDecoration(
            labelText: 'Error State',
            hintText: 'Something went wrong',
            errorText: 'This field is required',
            prefixIcon: Icon(Icons.error_outline, size: AppIconSize.md),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  //              CARDS SECTION
  // ================================================================
  Widget _buildCardsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cards',
          style: textTheme.headlineSmall,
        ),
         AppGap.md,
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filled Card', style: textTheme.titleLarge),
                 AppGap.sm,
                Text(
                  'This is an example of a filled card with elevation and rounded corners.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
         AppGap.sm,
        Card(
          color: colorScheme.surfaceVariant,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Surface Variant Card', style: textTheme.titleLarge),
                 AppGap.sm,
                Text(
                  'This card uses surface variant color for subtle differentiation.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  //              CHIPS SECTION
  // ================================================================
  Widget _buildChipsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chips',
          style: textTheme.headlineSmall,
        ),
         AppGap.md,
        Wrap(
          spacing: AppPadding.sm,
          runSpacing: AppPadding.sm,
          children: [
            InputChip(
              label: const Text('Input Chip'),
              onPressed: () {},
              avatar: Icon(Icons.person, size: AppIconSize.sm),
            ),
            FilterChip(
              label: const Text('Filter Chip'),
              selected: true,
              onSelected: (bool value) {},
            ),
            ActionChip(
              label: const Text('Action Chip'),
              onPressed: () {},
              avatar: Icon(Icons.star, size: AppIconSize.sm),
            ),
            Chip(
              label: const Text('Assist Chip'),
              backgroundColor: colorScheme.primaryContainer,
              deleteIcon: Icon(Icons.close, size: AppIconSize.sm),
              onDeleted: () {},
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  //              PROGRESS INDICATORS
  // ================================================================
  Widget _buildProgressIndicators(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Indicators',
        ),
         AppGap.md,
        const LinearProgressIndicator(),
         AppGap.md,
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }
}