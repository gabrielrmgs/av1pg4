import 'package:flutter/material.dart';
import 'package:to_do_list/models/category_model.dart';
import 'package:to_do_list/providers/task_provider.dart';

class DeleteCategoriesWidget extends StatelessWidget {
  const DeleteCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = TaskProvider();
    provider.loadCategorys();
    return AlertDialog(
      content: ListView.builder(
        itemCount: provider.categoryList.length,
        itemBuilder: (context, index) {
          CategoryModel categoryModel = provider.categoryList[index];
          return ListTile(
            title: Text(categoryModel.value),
          );
        },
      ),
    );
  }
}
