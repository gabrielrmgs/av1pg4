// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TaskModel {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime dueDate;
  String category;
  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.dueDate,
    required this.category,
  });

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, isCompleted: $isCompleted, dueDate: $dueDate, category: $category)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'category': category,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted: map['isCompleted'] as bool,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      category: map['category'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
