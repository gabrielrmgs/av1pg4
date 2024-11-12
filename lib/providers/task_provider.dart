// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list/models/category_model.dart';

import 'package:to_do_list/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> taskList = [];
  List<CategoryModel> categoryList = [];
  List<DropdownMenuItem<String>> dropdownCategoriesList = [];
  List<TaskModel> filteredTaskList = [];
  String dropdownValue = 'Todas';
  bool tasksIsEmpty = false;

  final String url = 'https://to-do-list-a8c09-default-rtdb.firebaseio.com/';

  Future<void> loadData() async {
    await loadCategorys();
    await loadTasks();
  }

  Future<void> loadTasks() async {
    taskList.clear();
    final response = await http.get(Uri.parse('${url}tasks.json'));
    final data = jsonDecode(response.body);
    if (data == null || data == []) {
      tasksIsEmpty = true;
    } else {
      data.forEach((key, value) {
        value['id'] = key;
        taskList.add(TaskModel.fromMap(value));
      });
      tasksIsEmpty = false;
    }
    notifyListeners();
  }

  Future<void> loadCategorys() async {
    categoryList.clear();
    dropdownCategoriesList.clear();
    final response = await http.get(Uri.parse('${url}categorys.json'));
    final data = jsonDecode(response.body);
    data.forEach((key, data) {
      data['id'] = key;
      categoryList.add(CategoryModel.fromMap(data));
    });
    for (CategoryModel category in categoryList) {
      dropdownCategoriesList.add(
          DropdownMenuItem(value: category.value, child: Text(category.text)));
    }
    notifyListeners();
  }

  Future<void> saveNewTask(TaskModel newTask) async {
    await http.post(Uri.parse('${url}tasks.json'), body: newTask.toJson());
    await loadTasks();
    dropdownCallback(newTask.category);
  }

  Future<void> updateTask(TaskModel taskModel) async {
    await http.patch(Uri.parse('${url}tasks/${taskModel.id}.json'),
        body: taskModel.toJson());
    taskList[taskList.indexWhere(
      (element) {
        return taskModel.id == element.id;
      },
    )] = taskModel;
    notifyListeners();
  }

  Future<void> checked(TaskModel taskModel) async {
    await http.patch(Uri.parse('${url}tasks/${taskModel.id}.json'),
        body: taskModel.toJson());
  }

  Future<void> saveNewCategory(CategoryModel categoryModel) async {
    await http.post(Uri.parse('${url}categorys.json'),
        body: categoryModel.toJson());
    loadCategorys();
  }

  void dropdownCallback(String? selectedValue) {
    if (selectedValue is String) {
      dropdownValue = selectedValue;
      if (selectedValue == 'Todas') {
        filteredTaskList = taskList;
      } else {
        filteredTaskList = taskList.where((task) {
          return task.category.contains(selectedValue);
        }).toList();
      }
    }
    notifyListeners();
    //loadTasks();
  }

  Future<void> removeTask(TaskModel taskModel) async {
    await http.delete(Uri.parse('${url}tasks/${taskModel.id}.json'));
    loadTasks();
  }

  Future<void> removeCategory(CategoryModel categoryModel) async {
    await http.delete(Uri.parse('${url}categorys/${categoryModel.id}.json'));
    loadCategorys();
  }

  Future<void> removeAllTasks() async {
    await http.delete(Uri.parse('${url}tasks.json'));
    loadTasks();
  }
}
