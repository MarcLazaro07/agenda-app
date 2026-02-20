import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CategoryModel {
  final String id;
  final String name;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
  });

  CategoryModel copyWith({String? name, Color? color}) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 3;

  @override
  CategoryModel read(BinaryReader reader) {
    return CategoryModel(
      id: reader.readString(),
      name: reader.readString(),
      color: Color(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.color.toARGB32());
  }
}
