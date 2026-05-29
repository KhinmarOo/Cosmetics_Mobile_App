import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final _supabase = Supabase.instance.client;

  Future<List<ProductModel>> getProducts() async {
    final response = await _supabase
        .from('products')
        .select('*')
        .order('created_at', ascending: false);
    return (response as List<dynamic>)
        .map((e) => ProductModel.fromMap(e))
        .toList();
  }

  Future<List<ProductModel>> getProductsWithOffers() async {
    final products = await getProducts();
    final offerPrices = await _getOfferPriceMap();
    return _applyOfferPrices(products, offerPrices);
  }

  Future<List<ProductModel>> getPopularProductsWithOffers({
    int limit = 4,
  }) async {
    final popularIds = await _getPopularProductIds(limit: limit);
    if (popularIds.isEmpty) return [];

    final productResponse = await _supabase
        .from('products')
        .select('*')
        .inFilter('pro_id', popularIds);

    final productMap = <String, ProductModel>{};
    for (final item in (productResponse as List<dynamic>)) {
      final row = item as Map<String, dynamic>;
      final productId = row['pro_id']?.toString() ?? '';
      if (productId.isEmpty) continue;
      productMap[productId] = ProductModel.fromMap(row);
    }
    final offerPrices = await _getOfferPriceMap();

    return popularIds
        .map((id) => productMap[id])
        .whereType<ProductModel>()
        .map(
          (product) => product.copyWith(salePrice: offerPrices[product.proId]),
        )
        .toList();
  }

  Future<List<String>> _getPopularProductIds({required int limit}) async {
    try {
      final response = await _supabase.rpc(
        'get_popular_product_ids',
        params: {'result_limit': limit},
      );

      final rows = response as List<dynamic>;
      return rows
          .map((item) => (item as Map<String, dynamic>)['pro_id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (_) {
      final itemResponse = await _supabase
          .from('order_items')
          .select('pro_id, ot_qty');

      final totals = <String, int>{};
      for (final item in (itemResponse as List<dynamic>)) {
        final row = item as Map<String, dynamic>;
        final productId = row['pro_id']?.toString() ?? '';
        if (productId.isEmpty) continue;
        totals[productId] =
            (totals[productId] ?? 0) + ((row['ot_qty'] as num?)?.toInt() ?? 1);
      }

      final popularIds = totals.entries.toList()
        ..sort((a, b) {
          final quantityCompare = b.value.compareTo(a.value);
          if (quantityCompare != 0) return quantityCompare;
          return a.key.compareTo(b.key);
        });

      return popularIds.take(limit).map((entry) => entry.key).toList();
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _supabase.from('products').insert(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _supabase
        .from('products')
        .update(data)
        .eq('pro_id', id)
        .select('pro_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception(
        "Product was not updated. Check product id or update policy.",
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await _supabase
        .from('products')
        .delete()
        .eq('pro_id', id)
        .select('pro_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception(
        "Product was not deleted. Check product id or delete policy.",
      );
    }
  }

  Future<Map<String, double>> _getOfferPriceMap() async {
    final response = await _supabase
        .from('offers')
        .select('pro_id, offer_price');

    final offerPrices = <String, double>{};
    for (final item in (response as List<dynamic>)) {
      final row = item as Map<String, dynamic>;
      final productId = row['pro_id']?.toString() ?? '';
      if (productId.isEmpty) continue;
      offerPrices[productId] = (row['offer_price'] as num?)?.toDouble() ?? 0;
    }

    return offerPrices;
  }

  List<ProductModel> _applyOfferPrices(
    List<ProductModel> products,
    Map<String, double> offerPrices,
  ) {
    return products
        .map(
          (product) => product.copyWith(salePrice: offerPrices[product.proId]),
        )
        .toList();
  }
}
