// lib/presentation/screens/category/category_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/add_category_dialog.dart';


class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _categoryType = "income"; // default value

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Argument ကနေ type ကို ယူပါ
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final newType = args["type"] as String? ?? "income";

      // 🔥 Simplification: Type ပြောင်းမှသာ update လုပ်ပါ
      if (newType != _categoryType) {
        setState(() {
          _categoryType = newType;
        });
      }
    }
    // ViewModel က stream နဲ့ auto listen လုပ်ထားပြီးဖြစ်လို့ loadCategories() ကို ခေါ်စရာမလိုတော့ပါ
  }


  @override
  Widget build(BuildContext context) {
    final type = _categoryType;
    final categoryVM = Provider.of<CategoryViewModel>(context);

    // 🔥 Fix 2: Type အလိုက် Categories List ကို ဆွဲထုတ်ခြင်း
    final categories = categoryVM.getCategoriesByType(type);

    return Scaffold(
      appBar: AppBar(
        title: Text("$type Categories"), // Type ကို Title မှာပြလိုက်ပါ
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddCategoryDialog(type: type),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: categoryVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(child: Text("No $type categories found.")) // List အလွတ်ဖြစ်ရင် ပြရန်
          : ListView.builder(
        // 🔥 categories List အသစ်ကို သုံးပါ
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index]; // categories List အသစ်ကို သုံးပါ
          return ListTile(
            title: Text(c.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, type, c.id, c.name);
                  },
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // CRUD methods တွေက type ကို လက်ခံထားပြီးသားမို့ ပြင်စရာမလိုပါ
                    categoryVM.removeCategory(type, c.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String type, String categoryId, String oldName) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Provider.of<CategoryViewModel>(context, listen: false)
                    .editCategory(type, categoryId, newName);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}