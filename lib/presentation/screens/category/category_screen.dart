import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/viewmodels/category_viewmodel.dart';
import '../../../presentation/viewmodels/main_viewmodel.dart';
import '../../widgets/add_category_dialog.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();

    // Load categories based on type argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mainVM = Provider.of<MainViewModel>(context, listen: false);
      final type = mainVM.currentArguments?["type"] ?? "income";

      Provider.of<CategoryViewModel>(context, listen: false)
          .loadCategories(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainVM = Provider.of<MainViewModel>(context);
    final type = mainVM.currentArguments?["type"] ?? "income";
    final categoryVM = Provider.of<CategoryViewModel>(context);

    return Scaffold(

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
