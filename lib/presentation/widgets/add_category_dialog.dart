import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/category_viewmodel.dart';

class AddCategoryDialog extends StatelessWidget {
  final String type;

  AddCategoryDialog({super.key, required this.type});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Category"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: "Category Name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              Provider.of<CategoryViewModel>(context, listen: false)
                  .addCategory(type, name);
            }
            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
