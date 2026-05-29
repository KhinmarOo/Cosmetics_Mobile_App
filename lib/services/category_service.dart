import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from('categorys')
          .select('cat_id, cat_name')
          .order('cat_name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((e) => CategoryModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
  }

  Future<void> addCategory(String name) async {
    try {
      await _supabase.from('categorys').insert({
        'cat_name': name,
      });
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  Future<void> updateCategory(String id, String newName) async {
    try {
      await _supabase
          .from('categorys')
          .update({'cat_name': newName})
          .eq('cat_id', id);
    } catch (e) {
      throw Exception("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase
          .from('categorys')
          .delete()
          .eq('cat_id', id);
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }
}