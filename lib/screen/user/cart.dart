import 'package:flutter/material.dart';

import './checkout.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onBackPressed;
  final VoidCallback onOrderCompleted;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onBackPressed,
    required this.onOrderCompleted,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _parsePrice(String price) {
    final numericText = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericText) ?? 0;
  }

  String _formatPrice(int price) {
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = price.toString().replaceAllMapped(
      reg,
      (match) => '${match[1]},',
    );
    return "$formatted MMK";
  }

  int _totalAmount() {
    var totalAmount = 0;
    for (final item in widget.cartItems) {
      final price = _parsePrice(item["price"]?.toString() ?? "0");
      final quantity = item["quantity"] as int? ?? 1;
      totalAmount += price * quantity;
    }
    return totalAmount;
  }

  int _cartBadgeCount() {
    return widget.cartItems.fold<int>(
      0,
      (total, item) => total + (item["quantity"] as int? ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);
    const bgColor = Color(0xFFFFFCF2);
    const buttonTextColor = Color(0xFF4A4A4A);
    final mutedAmountColor = const Color(0xFF4A4A4A).withValues(alpha: 0.78);
    final totalCartBadgeCount = _cartBadgeCount();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                        "Shopping Cart",
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: goldColor,
                        size: 28,
                      ),
                      if (totalCartBadgeCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text(
                              totalCartBadgeCount > 99
                                  ? "99+"
                                  : "$totalCartBadgeCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        "Your cart is empty",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        final quantity = item["quantity"] as int? ?? 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _CartProductImage(
                                    imageUrl: item["image"]?.toString() ?? "",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"]?.toString() ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: darkBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["price"]?.toString() ?? "",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: darkBrown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _QuantityButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      widget.onUpdateQuantity(
                                        index,
                                        quantity > 1 ? quantity - 1 : 0,
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: darkBrown,
                                      ),
                                    ),
                                  ),
                                  _QuantityButton(
                                    icon: Icons.add,
                                    onTap: () {
                                      widget.onUpdateQuantity(
                                        index,
                                        quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount :",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: mutedAmountColor,
                        ),
                      ),
                      Text(
                        _formatPrice(_totalAmount()),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: mutedAmountColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD4AF37),
                          Color(0xFFF7F1E3),
                          Color(0xFFD4AF37),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.cartItems.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(
                                    cartItems: widget.cartItems,
                                    onOrderCompleted: widget.onOrderCompleted,
                                  ),
                                ),
                              );
                            },
                      child: const Text(
                        "Order",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: buttonTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2D1D15);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFF7F1E3), Color(0xFFD4AF37)],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: darkBrown),
      ),
    );
  }
}

class _CartProductImage extends StatelessWidget {
  final String imageUrl;

  const _CartProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Icon(Icons.spa_outlined, color: Color(0xFFD4AF37));
    }

    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image_outlined,
          color: Color(0xFFD4AF37),
        );
      },
    );
  }
}
