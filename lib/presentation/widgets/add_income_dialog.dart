import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/income_entity.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/title_viewmodel.dart';


class AddIncomeFullScreen extends StatefulWidget {
  const AddIncomeFullScreen({super.key});

  @override
  State<AddIncomeFullScreen> createState() => _AddIncomeFullScreenState();
}

class _AddIncomeFullScreenState extends State<AddIncomeFullScreen> {
  String? selectedCategoryId;
  String? selectedExistingTitleId;

  final TextEditingController newTitleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  bool useNewTitle = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<CategoryViewModel>().loadCategories("income");
    context.read<TitleViewModel>().loadTitles("income");
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoryViewModel>();
    final titleVM = context.watch<TitleViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Income"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CATEGORY
                const Text("Category"),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  items: catVM.categories
                      .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => selectedCategoryId = v);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // TITLE switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Use New Title"),
                    Switch(
                      value: useNewTitle,
                      onChanged: (v) {
                        setState(() {
                          useNewTitle = v;
                          selectedExistingTitleId = null;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // EXISTING TITLE
                if (!useNewTitle) ...[
                  const Text("Choose Title"),
                  DropdownButtonFormField<String>(
                    value: selectedExistingTitleId,
                    items: titleVM.titles
                        .map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name),
                    ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => selectedExistingTitleId = v);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

                // NEW TITLE FIELD
                if (useNewTitle) ...[
                  const Text("New Title"),
                  TextField(
                    controller: newTitleCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter title",
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Amount
                const Text("Amount"),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "0.00",
                  ),
                ),

                const SizedBox(height: 20),

                // date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date: ${selectedDate.toString().split(' ').first}"),
                    TextButton(
                      onPressed: pickDate,
                      child: const Text("Choose"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: saveIncome,
          child: const Text("Save Income"),
        ),
      ),
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

  Future<void> saveIncome() async {
    final incomeVM = context.read<IncomeViewModel>();
    final titleVM = context.read<TitleViewModel>();

    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;

    String finalTitleId = "";

    // new title
    if (useNewTitle) {
      final newName = newTitleCtrl.text.trim();
      if (newName.isEmpty) return;

      await titleVM.addTitle("income", newName);
      await titleVM.loadTitles("income");

      final created = titleVM.titles.firstWhere(
            (t) => t.name.toLowerCase() == newName.toLowerCase(),
      );

      finalTitleId = created.id;
    } else {
      if (selectedExistingTitleId == null) return;
      finalTitleId = selectedExistingTitleId!;
    }

    if (selectedCategoryId == null) return;

    final newIncome = IncomeEntity(
      id: "",
      titleId: finalTitleId,
      categoryId: selectedCategoryId!,
      amount: amount,
      date: selectedDate,
      createdAt: DateTime.now(),
    );

    await incomeVM.addIncome(newIncome);

    if (mounted) Navigator.pop(context);
  }
}
