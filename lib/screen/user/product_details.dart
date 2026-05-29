import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final void Function(ProductModel product, int quantity) onAddToCart;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  String _formatPrice(double price, {bool multiply = true}) {
    final total = multiply ? price * quantity : price;
    if (total == total.roundToDouble()) {
      return "${total.round()} MMK";
    }

    return "${total.toStringAsFixed(2)} MMK";
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.38,
                      color: const Color(0xFFFFF0F2),
                      child: _ProductHeroImage(
                        imageUrl: widget.product.proImage,
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.6),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: darkBrown,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.proName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ProductPrice(product: widget.product),
                            Row(
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: quantity > 1
                                      ? () => setState(() => quantity--)
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    "$quantity",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: () => setState(() => quantity++),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Product Description",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product.proDescription.isEmpty
                              ? "No description available."
                              : widget.product.proDescription,
                          style: TextStyle(
                            fontSize: 13,
                            color: darkBrown.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Total Price:",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          _formatPrice(widget.product.effectivePrice),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        foregroundColor: goldColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        widget.onAddToCart(widget.product, quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${widget.product.proName} ($quantity) added to cart.",
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        "Add To Cart",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPrice extends StatelessWidget {
  final ProductModel product;

  const _ProductPrice({required this.product});

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF4A4A4A);

    if (!product.hasSale) {
      return Text(
        product.displayPrice,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkBrown,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.displayPrice,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: darkBrown,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 1.4,
          ),
        ),
        Text(
          product.displaySalePrice,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade300 : const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _ProductHeroImage extends StatelessWidget {
  final String imageUrl;

  const _ProductHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.spa_outlined, size: 100, color: Color(0xFFD4AF37)),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 90,
            color: Color(0xFFD4AF37),
          ),
        );
      },
    );
  }
}
