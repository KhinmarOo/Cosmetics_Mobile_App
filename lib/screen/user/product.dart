import 'package:flutter/material.dart';
import '../../components/add_card_button.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'product_details.dart';

class ProductScreen extends StatefulWidget {
  final List<ProductModel> favoritedProducts;
  final ValueChanged<ProductModel> onFavoriteToggle;
  final void Function(ProductModel product, int quantity) onAddToCart;
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onCartPressed;
  final VoidCallback onBackPressed;

  const ProductScreen({
    super.key,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onCartPressed,
    required this.onBackPressed,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ProductModel>> _productsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProductsWithOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _cartItemCount() {
    return widget.cartItems.fold<int>(
      0,
      (total, item) => total + (item["quantity"] as int? ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    final cartCount = _cartItemCount();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: goldColor,
                          size: 20,
                        ),
                        onPressed: widget.onBackPressed,
                      ),
                      const Text(
                        "All Products",
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _CartIconButton(
                    count: cartCount,
                    onPressed: widget.onCartPressed,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4AF37),
                      Color(0xFFF7F1E3),
                      Color(0xFFD4AF37),
                    ],
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(
                      color: Color(0xFF2D1D15),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF2D1D15)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Failed to load products: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final products = (snapshot.data ?? [])
                      .where((product) => _matchesProductSearch(product))
                      .toList();
                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 100,
                    ),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isFav = widget.favoritedProducts.any(
                        (item) => item.proId == product.proId,
                      );

                      return _ProductCard(
                        product: product,
                        isFavorite: isFav,
                        onFavoriteToggle: widget.onFavoriteToggle,
                        onAddToCart: widget.onAddToCart,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesProductSearch(ProductModel product) {
    final normalizedQuery = _normalizeSearchText(_searchQuery);
    if (normalizedQuery.isEmpty) return true;

    final searchableText = _normalizeSearchText(
      "${product.proName} ${product.proDescription} ${product.displayPrice}",
    );
    final compactQuery = normalizedQuery.replaceAll(' ', '');
    final compactText = searchableText.replaceAll(' ', '');

    if (searchableText.contains(normalizedQuery) ||
        compactText.contains(compactQuery)) {
      return true;
    }

    final queryWords = normalizedQuery
        .split(' ')
        .where((word) => word.isNotEmpty);
    return queryWords.every(searchableText.contains);
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'[.,/#!$%^&*;:{}=+`~()\[\]<>?|"\\]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _CartIconButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _CartIconButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: goldColor),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? "99+" : "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isFavorite;
  final ValueChanged<ProductModel> onFavoriteToggle;
  final void Function(ProductModel product, int quantity) onAddToCart;

  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: product,
              onAddToCart: onAddToCart,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: goldColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => onFavoriteToggle(product),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: isFavorite ? const Color(0xFFE6B31E) : goldColor,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _ProductImage(imageUrl: product.proImage, size: 90),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.proName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D1D15),
              ),
            ),
            const SizedBox(height: 4),
            _ProductPrice(product: product),
            const SizedBox(height: 8),
            AddCardButton(onTap: () => _confirmAddToCart(context)),
          ],
        ),
      ),
    );
  }

  void _confirmAddToCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCF2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Add to Cart?",
            style: TextStyle(
              color: Color(0xFF2D1D15),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Do you want to add '${product.proName}' to your shopping cart?",
            style: const TextStyle(color: Color(0xFF2D1D15), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAddToCart(product, 1);
              },
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductPrice extends StatelessWidget {
  final ProductModel product;

  const _ProductPrice({required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.hasSale) {
      return Text(
        product.displayPrice,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D1D15),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.displayPrice,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1D15),
            decoration: TextDecoration.lineThrough,
            decorationThickness: 1.4,
          ),
        ),
        Text(
          product.displaySalePrice,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _ProductImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Icon(Icons.spa_outlined, size: 55, color: Color(0xFFD4AF37));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image_outlined,
            size: 50,
            color: Color(0xFFD4AF37),
          );
        },
      ),
    );
  }
}
