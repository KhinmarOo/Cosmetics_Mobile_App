import 'package:flutter/material.dart';
import '../../../components/add_card_button.dart';
import '../../../models/product_model.dart';
import '../product_details.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback? onSeeMore;
  final List<ProductModel> favoritedProducts;
  final ValueChanged<ProductModel> onFavoriteToggle;
  final void Function(ProductModel product, int quantity) onAddToCart;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    this.onSeeMore,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          "$title not available",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1D15),
                ),
              ),
              if (onSeeMore != null)
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text(
                    "See More..",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.64,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return _ProductCard(
                product: products[index],
                isFavorite: favoritedProducts.any(
                  (item) => item.proId == products[index].proId,
                ),
                onFavoriteToggle: onFavoriteToggle,
                onAddToCart: onAddToCart,
              );
            },
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: goldColor.withValues(alpha: 0.2)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
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
                      child: _ProductImage(
                        imageUrl: product.proImage,
                        size: 82,
                      ),
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
                  AddCardButton(
                    onTap: () => _confirmAddToCart(context, product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAddToCart(BuildContext context, ProductModel product) {
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
            size: 48,
            color: Color(0xFFD4AF37),
          );
        },
      ),
    );
  }
}
