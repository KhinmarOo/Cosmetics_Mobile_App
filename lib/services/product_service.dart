import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final _supabase = Supabase.instance.client;

  Future<List<ProductModel>> getProducts() async {
    final response = await _supabase.from('products').select('*');
    return (response as List<dynamic>).map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _supabase.from('products').insert(data);
  }
}