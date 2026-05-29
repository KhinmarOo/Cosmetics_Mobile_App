import 'package:flutter/material.dart';
import '../../components/bottom_nav_bar.dart';
import '../../models/product_model.dart';
import '../../services/wishlist_service.dart';
import 'account.dart';
import 'cart.dart';
import 'home.dart';
import 'product.dart';
import 'wishlist.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  final WishlistService _wishlistService = WishlistService();
  final List<Map<String, dynamic>> _cartProducts = [];
  final List<ProductModel> _favoritedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _changeTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void _goBackToPreviousTab() {
    _changeTab(_previousIndex);
  }

  void _addToCart(ProductModel product, int quantity) {
    setState(() {
      final index = _cartProducts.indexWhere(
        (item) => item["id"] == product.proId,
      );

      if (index >= 0) {
        _cartProducts[index]["quantity"] =
            (_cartProducts[index]["quantity"] as int) + quantity;
      } else {
        _cartProducts.add(product.toCartItem(quantity));
      }
    });
  }

  void _updateCartQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartProducts.removeAt(index);
      } else {
        _cartProducts[index]["quantity"] = newQuantity;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cartProducts.clear();
    });
  }

  Future<void> _loadWishlist() async {
    try {
      final wishlistProducts = await _wishlistService.getWishlistProducts();
      if (!mounted) return;
      setState(() {
        _favoritedProducts
          ..clear()
          ..addAll(wishlistProducts);
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage("Wishlist load failed: $e");
    }
  }

  void _toggleFavorite(ProductModel product) {
    final wasFavorite = _favoritedProducts.any(
      (item) => item.proId == product.proId,
    );

    setState(() {
      if (wasFavorite) {
        _favoritedProducts.removeWhere((item) => item.proId == product.proId);
      } else {
        _favoritedProducts.add(product);
      }
    });

    _syncWishlistToggle(product, wasFavorite: wasFavorite);
  }

  Future<void> _syncWishlistToggle(
    ProductModel product, {
    required bool wasFavorite,
  }) async {
    try {
      if (wasFavorite) {
        await _wishlistService.removeWishlistProduct(product.proId);
      } else {
        await _wishlistService.addWishlistProduct(product.proId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasFavorite) {
          final exists = _favoritedProducts.any(
            (item) => item.proId == product.proId,
          );
          if (!exists) _favoritedProducts.add(product);
        } else {
          _favoritedProducts.removeWhere((item) => item.proId == product.proId);
        }
      });
      _showMessage("Wishlist update failed: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Widget> _pages() {
    return [
      HomeScreen(
        favoritedProducts: _favoritedProducts,
        onFavoriteToggle: _toggleFavorite,
        onAddToCart: _addToCart,
        cartItems: _cartProducts,
        onCartPressed: () {
          _changeTab(3);
        },
        onSeeMore: () {
          _changeTab(1);
        },
      ),
      ProductScreen(
        favoritedProducts: _favoritedProducts,
        onFavoriteToggle: _toggleFavorite,
        onAddToCart: _addToCart,
        cartItems: _cartProducts,
        onUpdateQuantity: _updateCartQuantity,
        onCartPressed: () {
          _changeTab(3);
        },
        onBackPressed: _goBackToPreviousTab,
      ),
      WishlistScreen(
        favoritedProducts: _favoritedProducts,
        onFavoriteToggle: _toggleFavorite,
        onAddToCart: _addToCart,
        onBackPressed: _goBackToPreviousTab,
      ),
      CartScreen(
        cartItems: _cartProducts,
        onUpdateQuantity: _updateCartQuantity,
        onBackPressed: _goBackToPreviousTab,
        onOrderCompleted: _clearCart,
      ),
      const AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages()),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _changeTab,
      ),
    );
  }
}
