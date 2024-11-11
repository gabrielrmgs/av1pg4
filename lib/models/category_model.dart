import 'dart:convert';

class CategoryModel {
  String value;
  String text;
  CategoryModel({
    required this.value,
    required this.text,
  });

  @override
  String toString() => 'CategoryModel(value: $value, text: $text)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value,
      'text': text,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      value: map['value'] as String,
      text: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
