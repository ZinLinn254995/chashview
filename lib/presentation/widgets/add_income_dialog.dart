import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/title_viewmodel.dart';

class AddIncomeFullScreen extends StatefulWidget {
  const AddIncomeFullScreen({super.key});

  @override
  State<AddIncomeFullScreen> createState() => _AddIncomeFullScreenState();
}

class _AddIncomeFullScreenState extends State<AddIncomeFullScreen> {
  final _formKey = GlobalKey<FormState>();

  // IDs for Logic
  String? selectedCategoryId;
  String? selectedExistingTitleId;

  // Controllers for Input & Display
  final TextEditingController _categoryDisplayCtrl = TextEditingController();
  final TextEditingController _titleDisplayCtrl = TextEditingController();
  final TextEditingController _newTitleInputCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();

  bool useNewTitle = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategories("income");
      context.read<TitleViewModel>().loadTitles("income");
    });
  }

  @override
  void dispose() {
    _categoryDisplayCtrl.dispose();
    _titleDisplayCtrl.dispose();
    _newTitleInputCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String get formattedDate {
    return "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
  }

  // 🔥 Decoration
  InputDecoration buildDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoryViewModel>();
    final titleVM = context.watch<TitleViewModel>();
    final theme = Theme.of(context);

    // Filter Titles based on Category
    final filteredTitles = titleVM.titles
        .where((t) => t.categoryId == selectedCategoryId)
        .toList();

    // Logic to check if fields should be enabled
    final bool isCategoryAvailable = catVM.categories.isNotEmpty;
    final bool isTitleAvailable = filteredTitles.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Add Income"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: saveIncome,
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. CATEGORY SELECTOR
                TextFormField(
                  controller: _categoryDisplayCtrl,
                  readOnly: true,
                  enabled: isCategoryAvailable,
                  decoration: buildDecoration(
                    isCategoryAvailable ? "Category" : "No Category Available",
                    hint: isCategoryAvailable ? "Select Category" : null,
                  ),
                  validator: (value) =>
                  selectedCategoryId == null ? "Please select a category" : null,
                  onTap: () {
                    if (isCategoryAvailable) {
                      _showCategoryDialog(catVM.categories);
                    }
                  },
                ),

                const SizedBox(height: 20),

                // 2. TITLE SECTION
                if (selectedCategoryId != null) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Create New Title",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: useNewTitle,
                    onChanged: (v) {
                      setState(() {
                        useNewTitle = v;
                        selectedExistingTitleId = null;
                        _titleDisplayCtrl.clear();
                        _newTitleInputCtrl.clear();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  if (!useNewTitle)
                    TextFormField(
                      controller: _titleDisplayCtrl,
                      readOnly: true,
                      enabled: isTitleAvailable,
                      decoration: buildDecoration(
                        isTitleAvailable ? "Title" : "No Title Available",
                        hint: isTitleAvailable ? "Select Title" : null,
                      ),
                      validator: (value) {
                        if (!useNewTitle && selectedExistingTitleId == null) {
                          return isTitleAvailable
                              ? "Please select a title"
                              : "No title available, please create new";
                        }
                        return null;
                      },
                      onTap: () {
                        if (isTitleAvailable) {
                          _showTitleDialog(filteredTitles);
                        }
                      },
                    )
                  else
                    TextFormField(
                      controller: _newTitleInputCtrl,
                      decoration:
                      buildDecoration("New Title Name", hint: "Enter name"),
                      validator: (value) {
                        if (useNewTitle) {
                          return (value == null || value.trim().isEmpty)
                              ? "Please enter a title name"
                              : null;
                        }
                        return null;
                      },
                    ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      isCategoryAvailable
                          ? "Select a category to choose title"
                          : "Please add categories first",
                      style:
                      TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 20),

                // 3. AMOUNT
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: buildDecoration("Amount", hint: "0.00"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter amount";
                    final amt = double.tryParse(value);
                    if (amt == null || amt <= 0) return "Invalid amount";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 4. DATE
                InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: buildDecoration("Date"),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Custom Dialog for Category (FIXED: Standard RadioListTile)
  Future<void> _showCategoryDialog(List<CategoryEntity> categories) async {
    String? tempSelectedId = selectedCategoryId;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Category"),
              contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: SingleChildScrollView(
                  // RadioGroup ကို ဖြုတ်ပြီး ရိုးရိုး Column သုံးမယ်
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
                        // Category ပြောင်းရင် Title ကို Reset ချ
                        selectedExistingTitleId = null;
                        _titleDisplayCtrl.clear();
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

  // 🔥 Custom Dialog for Title (FIXED: Standard RadioListTile)
  Future<void> _showTitleDialog(List<TitleEntity> titles) async {
    String? tempSelectedId = selectedExistingTitleId;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Title"),
              contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: titles.map((item) {
                      return RadioListTile<String>(
                        title: Text(item.name),
                        value: item.id,
                        // ✅ groupValue ထည့်မယ်
                        groupValue: tempSelectedId,
                        // ✅ onChanged ထည့်မှ Enable ဖြစ်မယ်
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
                        selectedExistingTitleId = tempSelectedId;
                        _titleDisplayCtrl.text = titles
                            .firstWhere((t) => t.id == tempSelectedId)
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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // 🔥 Saving Logic
  void saveIncome() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _SaveStatusDialog(
          onProcess: () async {
            final incomeVM = context.read<IncomeViewModel>();
            final titleVM = context.read<TitleViewModel>();
            final amount = double.parse(_amountCtrl.text.trim());
            String finalTitleId = "";

            if (useNewTitle) {
              final newName = _newTitleInputCtrl.text.trim();
              await titleVM.addTitle("income", newName, selectedCategoryId!);
              await titleVM.loadTitles("income");

              final created = titleVM.titles.firstWhere(
                    (t) =>
                t.name.toLowerCase() == newName.toLowerCase() &&
                    t.categoryId == selectedCategoryId,
                orElse: () =>
                throw Exception("Failed to retrieve new title ID"),
              );
              finalTitleId = created.id;
            } else {
              finalTitleId = selectedExistingTitleId!;
            }

            final newIncome = IncomeEntity(
              id: "",
              titleId: finalTitleId,
              amount: amount,
              date: selectedDate,
              createdAt: DateTime.now(),
            );

            await incomeVM.addIncome(newIncome);
          },
          onSuccess: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

// 👇 Save Status Dialog
class _SaveStatusDialog extends StatefulWidget {
  final Future<void> Function() onProcess;
  final VoidCallback onSuccess;

  const _SaveStatusDialog({
    required this.onProcess,
    required this.onSuccess,
  });

  @override
  State<_SaveStatusDialog> createState() => _SaveStatusDialogState();
}

class _SaveStatusDialogState extends State<_SaveStatusDialog> {
  int _status = 0;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  Future<void> _startProcess() async {
    try {
      await widget.onProcess();
      if (!mounted) return;
      setState(() => _status = 1);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 2;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_status == 0) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text("Saving data...",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ] else if (_status == 1) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 20),
              const Text("Saved Successfully!",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ] else ...[
              const Icon(Icons.error, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              const Text("Failed to Save",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(_errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          ],
        ),
      ),
    );
  }
}