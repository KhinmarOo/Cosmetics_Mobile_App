import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import 'product_service.dart';

class WishlistService {
  final _supabase = Supabase.instance.client;
  final ProductService _productService = ProductService();

  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException("Please login again to use wishlist");
    }
    return userId;
  }

  Future<List<ProductModel>> getWishlistProducts() async {
    final userId = _currentUserId;
    final response = await _supabase
        .from('wishlists')
        .select('user_id, pro_id, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final wishlistItems = (response as List<dynamic>)
        .map((item) => WishlistModel.fromMap(item as Map<String, dynamic>))
        .where((item) => item.productId.isNotEmpty)
        .toList();

    if (wishlistItems.isEmpty) return [];

    final wishlistProductIds = wishlistItems
        .map((item) => item.productId)
        .toSet();
    final products = await _productService.getProductsWithOffers();
    final productMap = {
      for (final product in products)
        if (wishlistProductIds.contains(product.proId)) product.proId: product,
    };

    return wishlistItems
        .map((item) => productMap[item.productId])
        .whereType<ProductModel>()
        .toList();
  }

  Future<void> addWishlistProduct(String productId) async {
    final userId = _currentUserId;
    final existing = await _supabase
        .from('wishlists')
        .select('pro_id')
        .eq('user_id', userId)
        .eq('pro_id', productId)
        .maybeSingle();

    if (existing != null) return;

    final wishlist = WishlistModel(
      id: '',
      userId: userId,
      productId: productId,
    );

    await _supabase.from('wishlists').insert(wishlist.toInsertMap());
  }

  Future<void> removeWishlistProduct(String productId) async {
    await _supabase
        .from('wishlists')
        .delete()
        .eq('user_id', _currentUserId)
        .eq('pro_id', productId);
  }
}
