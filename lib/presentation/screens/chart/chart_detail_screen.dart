import 'package:flutter/material.dart';

class ChartDetailScreen extends StatefulWidget {
  final String title;
  final Widget Function() chartBuilder; // ✅ chartBuilder parameter

  const ChartDetailScreen({
    super.key,
    required this.title,
    required this.chartBuilder,
  });

  @override
  State<ChartDetailScreen> createState() => _ChartDetailScreenState();
}

class _ChartDetailScreenState extends State<ChartDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.chartBuilder(), // ✅ chartBuilder ကိုခေါ်သုံးပါ
      ),
    );
  }
}