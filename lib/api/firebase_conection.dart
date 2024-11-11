import 'dart:convert';

import 'package:to_do_list/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list/models/task_model.dart';

abstract class FirebaseConection {
  static List<CategoryModel> categorys = [];
  static List<TaskModel> tasksProvider = [];

  static Future<void> loadData() async {
    await loadCategorys();
    await loadTasks();
  }

  static const String url =
      "https://to-do-list-a8c09-default-rtdb.firebaseio.com/";

  static Future<void> loadCategorys() async {
    final response = await http.get(Uri.parse('${url}categorys.json'));
    final data = jsonDecode(response.body);
    data.forEach((key, data) {
      categorys.add(CategoryModel.fromMap(data));
    });
  }

  static Future<void> loadTasks() async {
    final response = await http.get(Uri.parse('${url}tasks.json'));
    final data = jsonDecode(response.body);
    data.forEach(
      (key, data) {
        data['id'] = key;
        tasksProvider.add(TaskModel.fromMap(data));
      },
    );
  }

  static void saveNewCategory(CategoryModel categoryModel) {
    http.post(Uri.parse('${url}categorys.json'), body: categoryModel.toJson());
  }

  static void saveNewTask(TaskModel newTask) {
    http.post(Uri.parse('${url}tasks.json'), body: newTask.toJson());
    loadTasks();
  }

  static Future<void> updateTask(TaskModel taskModel) async {
    http.patch(Uri.parse('${url}tasks/${taskModel.id}.json'),
        body: taskModel.toJson());
  }

  static Future<void> removeTask(TaskModel taskModel) async {
    http.delete(Uri.parse('${url}tasks/${taskModel.id}.json'));
  }

  static Future<void> removeAllTasks() async {
    http.delete(Uri.parse('${url}tasks.json'));
  }
}
