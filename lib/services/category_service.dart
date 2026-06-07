import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;
  static const String _categoryTable = 'categorys';
  static const String _categoryImageBucket = 'categorys_images';

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from(_categoryTable)
          .select('cat_id, cat_name, cat_image')
          .order('cat_name', ascending: true);

      return (response as List<dynamic>)
          .map((item) => CategoryModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
  }

  Future<void> addCategory(String name, {String? imageUrl}) async {
    try {
      await _supabase.from(_categoryTable).insert({
        'cat_name': name.trim(),
        'cat_image': imageUrl?.trim(),
      });
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  Future<void> updateCategory(
    String id,
    String newName, {
    String? imageUrl,
  }) async {
    try {
      await _supabase
          .from(_categoryTable)
          .update({'cat_name': newName.trim(), 'cat_image': imageUrl?.trim()})
          .eq('cat_id', id);
    } catch (e) {
      throw Exception("Error updating category: $e");
    }
  }

  Future<String> uploadCategoryImage(File image) async {
    try {
      final fileExtension = image.path.split('.').last.toLowerCase();
      final safeExtension = fileExtension.isEmpty ? 'png' : fileExtension;
      final fileName =
          'categories/${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
      final storage = _supabase.storage.from(_categoryImageBucket);

      await storage.upload(fileName, image);
      return storage.getPublicUrl(fileName);
    } catch (e) {
      throw Exception("Error uploading category image: $e");
    }
  }

  Future<bool> categoryHasProducts(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select('pro_id')
          .eq('cat_id', id)
          .limit(1);

      return (response as List<dynamic>).isNotEmpty;
    } catch (e) {
      throw Exception("Error checking category products: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from(_categoryTable).delete().eq('cat_id', id);
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }
}
