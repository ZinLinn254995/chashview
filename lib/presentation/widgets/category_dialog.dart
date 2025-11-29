import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/category_viewmodel.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryDialog extends StatefulWidget {
  final String type; // 'income' or 'expense'
  final CategoryEntity? category; // null = Add, not null = Edit

  const CategoryDialog({
    super.key,
    required this.type,
    this.category,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    // Edit mode ဆိုရင် existing name ကို pre-fill
    if (_isEditMode) {
      _controller.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveOrUpdateCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final categoryVM = context.read<CategoryViewModel>();
      final name = _controller.text.trim();

      if (_isEditMode) {
        // Edit mode - name တူတူပဲဆိုရင် update မလုပ်ဘူး
        if (name == widget.category!.name) {
          if (mounted) Navigator.of(context).pop();
          return;
        }

        await categoryVM.editCategory(
            widget.type,
            widget.category!.id,
            name
        );
      } else {
        // Add mode
        await categoryVM.addCategory(widget.type, name);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = widget.type[0].toUpperCase() + widget.type.substring(1);
    final dialogTitle = _isEditMode ? "Edit $title Category" : "Add $title Category";
    final buttonText = _isEditMode ? "Update" : "Save";

    return AlertDialog(
      title: Text(
        dialogTitle,
        style: textTheme.titleMedium, // Adjusted style
      ),

      // UPDATED: Shape to match Amount Dialog
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: colorScheme.surface, // Match Amount Dialog background

      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: "Enter category name",
            // UPDATED: TextField Style to match Amount Dialog
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainer, // Similar to Amount Dialog's fill
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            isDense: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Category name cannot be empty';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        // UPDATED: Button to FilledButton
        FilledButton(
          onPressed: _isSubmitting ? null : _saveOrUpdateCategory,
          child: _isSubmitting
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.onPrimary,
            ),
          )
              : Text(buttonText),
        ),
      ],
    );
  }
}