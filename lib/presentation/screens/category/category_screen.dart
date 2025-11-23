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
  String _categoryType = "income";
  bool _didLoadCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Argument ကနေ type ကို ယူပါ
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      // Argument ကနေ ယူရမယ့် type ကို update လုပ်
      final newType = args["type"] as String? ?? "income";

      // 2. Type ပြောင်းမှသာ Load လုပ်ရမယ့် အခြေအနေ (ဒါမှမဟုတ် ပထမဆုံးအကြိမ် load လုပ်ဖို့)
      if (newType != _categoryType || !_didLoadCategories) {

        _categoryType = newType;

        // 3. Data ကို တစ်ကြိမ်သာ Load လုပ်ပါ (မပြီးခင် ထပ်မ load မိအောင်)
        Provider.of<CategoryViewModel>(context, listen: false)
            .loadCategories(_categoryType);

        _didLoadCategories = true; // Load လုပ်ပြီးပြီဟု မှတ်သား
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final type = _categoryType;
    final categoryVM = Provider.of<CategoryViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
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
          : ListView.builder(
        itemCount: categoryVM.categories.length,
        itemBuilder: (context, index) {
          final c = categoryVM.categories[index];
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