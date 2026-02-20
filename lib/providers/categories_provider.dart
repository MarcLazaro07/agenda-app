import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_service.dart';
import '../models/category_model.dart';

class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  final DatabaseService _dbServer;

  CategoriesNotifier(this._dbServer) : super(_dbServer.getCategories());

  Future<void> addCategory(CategoryModel category) async {
    await _dbServer.saveCategory(category);
    state = _dbServer.getCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _dbServer.saveCategory(category);
    state = _dbServer.getCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _dbServer.deleteCategory(id);
    state = _dbServer.getCategories();
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>((ref) {
      return CategoriesNotifier(DatabaseService());
    });
