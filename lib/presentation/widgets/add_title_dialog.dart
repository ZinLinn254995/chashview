import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ယူနစ်များ (Entities and ViewModels) ကို သင့်ပရောဂျက်၏ တည်နေရာအတိုင်း ပြောင်းလဲရန် လိုအပ်နိုင်ပါသည်။
import '../../domain/entities/category_entity.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/title_viewmodel.dart';

class AddTitleDialog extends StatefulWidget {
  final String type; // 'income' or 'expense'

  const AddTitleDialog({super.key, required this.type});

  @override
  State<AddTitleDialog> createState() => _AddTitleDialogState();
}

class _AddTitleDialogState extends State<AddTitleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryDisplayCtrl = TextEditingController();
  final TextEditingController _titleNameCtrl = TextEditingController();

  String? selectedCategoryId;

  // 💡 Saving Status Variables
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load categories if needed
      final catVM = context.read<CategoryViewModel>();
      if (widget.type == 'income' && catVM.incomeCategories.isEmpty) {
        catVM.getCategoriesByType('income');
      } else if (widget.type == 'expense' && catVM.expenseCategories.isEmpty) {
        catVM.getCategoriesByType('expense');
      }
    });
  }

  @override
  void dispose() {
    _categoryDisplayCtrl.dispose();
    _titleNameCtrl.dispose();
    super.dispose();
  }

  InputDecoration buildDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final catVM = context.watch<CategoryViewModel>();

    final categories = widget.type == 'income'
        ? catVM.incomeCategories
        : catVM.expenseCategories;

    final bool isCategoryAvailable = categories.isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(
        child: Text(
          "Add ${widget.type == 'income' ? 'Income' : 'Expense'} Title",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Dialog size adjustment
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. CATEGORY SELECTOR
              TextFormField(
                controller: _categoryDisplayCtrl,
                readOnly: true,
                enabled: isCategoryAvailable && !_isSaving, // Disable when saving
                decoration: buildDecoration(
                  isCategoryAvailable ? "Category" : "No Category",
                  hint: isCategoryAvailable
                      ? "Select Category"
                      : "Add categories first",
                ),
                // Validation check for Save button press
                validator: (value) => selectedCategoryId == null
                    ? "Please select a category"
                    : null,
                onTap: () {
                  if (isCategoryAvailable && !_isSaving) {
                    _showCategoryDialog(categories);
                  }
                },
              ),

              const SizedBox(height: 16),

              // 2. TITLE NAME INPUT
              TextFormField(
                controller: _titleNameCtrl,
                enabled: !_isSaving, // Disable when saving
                decoration:
                buildDecoration("Title Name", hint: "Enter title name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a title name";
                  }
                  return null;
                },
              ),

              // 3. 💡 Error Message Display
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Error: $_saveError",
                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button - Disabled while saving
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        // Save Button - Shows Loading Spinner when saving
        ElevatedButton(
          onPressed: _isSaving ? null : _saveTitle,
          child: _isSaving
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.onPrimary,
            ),
          )
              : const Text("Save"),
        ),
      ],
    );
  }

  Future<void> _showCategoryDialog(List<CategoryEntity> categories) async {
    // ... (Category dialog logic remains the same) ...
    String? tempSelectedId = selectedCategoryId;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                  "Select ${widget.type == 'income' ? 'Income' : 'Expense'} Category"),
              contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categories.map((item) {
                      return RadioListTile<String>(
                        title: Text(item.name),
                        value: item.id,
                        groupValue: tempSelectedId,
                        onChanged: (value) {
                          setStateDialog(() {
                            tempSelectedId = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (tempSelectedId != null) {
                      setState(() {
                        selectedCategoryId = tempSelectedId;
                        _categoryDisplayCtrl.text = categories
                            .firstWhere((c) => c.id == tempSelectedId)
                            .name;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveTitle() async {
    // 1. Validate the form.
    if (!_formKey.currentState!.validate()) {
      setState(() => _saveError = null); // Clear previous error if validation fails on input fields
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null; // Clear previous error
    });

    try {
      final titleVM = context.read<TitleViewModel>();
      final titleName = _titleNameCtrl.text.trim();

      // 2. Perform the save operation
      await titleVM.addTitle(widget.type, titleName, selectedCategoryId!);

      // 3. Success: Show success momentarily and close
      // Optional: You can show a success icon briefly on the button here before pop.
      // For simplicity, we directly pop the dialog after a small delay.
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context); // Close the AddTitleDialog
      }
    } catch (e) {
      // 4. Error: Update state to show error message
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = e.toString().contains("Exception:")
              ? e.toString().split("Exception:").last.trim()
              : "An unexpected error occurred.";
        });
      }
    }
  }
}

// -----------------------------------------------------------------------------
// _SaveStatusDialog class is REMOVED as requested.
// -----------------------------------------------------------------------------