import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;

  // 1. Get Categories (Data အားလုံးယူမယ်)
  Future<List<CategoryModel>> getCategories() async {
    try {
      // Supabase ကနေ cat_id နဲ့ cat_name ကိုပဲ ရွေးထုတ်ပြီး ယူမယ်
      final response = await _supabase
          .from('categorys')
          .select('cat_id, cat_name')
          .order('cat_name', ascending: true); // နာမည်အလိုက် အစဉ်လိုက်စီမယ်

      final List<dynamic> data = response as List<dynamic>;
      
      // Data တွေကို Model List အဖြစ် ပြောင်းပေးမယ်
      return data.map((e) => CategoryModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
  }

  // 2. Add Category (အသစ်ထည့်မယ်)
  Future<void> addCategory(String name) async {
    try {
      await _supabase.from('categorys').insert({
        'cat_name': name,
      });
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  // 3. Update Category (ပြင်မယ်)
  Future<void> updateCategory(String id, String newName) async {
    try {
      await _supabase
          .from('categorys')
          .update({'cat_name': newName})
          .eq('cat_id', id); // ID ကိုအခြေခံပြီး ပြင်မယ်
    } catch (e) {
      throw Exception("Error updating category: $e");
    }
  }

  // 4. Delete Category (ဖျက်မယ်)
  Future<void> deleteCategory(String id) async {
    try {
      await _supabase
          .from('categorys')
          .delete()
          .eq('cat_id', id); // ID ကိုအခြေခံပြီး ဖျက်မယ်
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }
}