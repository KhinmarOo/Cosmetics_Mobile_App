import 'package:flutter/material.dart';
import '../../components/add_card_button.dart';
import '../../models/product_model.dart';

class WishlistScreen extends StatelessWidget {
  final List<ProductModel> favoritedProducts;
  final ValueChanged<ProductModel> onFavoriteToggle;
  final void Function(ProductModel product, int quantity) onAddToCart;
  final VoidCallback onBackPressed;

  const WishlistScreen({
    super.key,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: goldColor,
                      size: 20,
                    ),
                    onPressed: onBackPressed,
                  ),
                  const Text(
                    "Wishlist",
                    style: TextStyle(
                      color: goldColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favoritedProducts.isEmpty
                  ? const Center(
                      child: Text(
                        "No favorites added yet!",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: favoritedProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final product = favoritedProducts[index];

                        return _WishlistCard(
                          product: product,
                          onFavoriteToggle: onFavoriteToggle,
                          onAddToCart: onAddToCart,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final ProductModel product;
  final ValueChanged<ProductModel> onFavoriteToggle;
  final void Function(ProductModel product, int quantity) onAddToCart;

  const _WishlistCard({
    required this.product,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Container(
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
              child: const Icon(
                Icons.favorite_rounded,
                size: 20,
                color: goldColor,
              ),
            ),
          ),
          Expanded(
            child: Center(child: _WishlistImage(imageUrl: product.proImage)),
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
          _WishlistPrice(product: product),
          const SizedBox(height: 8),
          AddCardButton(onTap: () => _confirmAddToCart(context)),
        ],
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

class _WishlistPrice extends StatelessWidget {
  final ProductModel product;

  const _WishlistPrice({required this.product});

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

class _WishlistImage extends StatelessWidget {
  final String imageUrl;

  const _WishlistImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Icon(Icons.spa_outlined, size: 55, color: Color(0xFFD4AF37));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 90,
        height: 90,
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
