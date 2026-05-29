import 'package:flutter/material.dart';

import '../../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderCompleted;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.onOrderCompleted,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final OrderService _orderService = OrderService();
  bool _isSubmitting = false;

  int _getCartCount() {
    var totalCount = 0;
    for (final item in widget.cartItems) {
      totalCount += item["quantity"] as int? ?? 0;
    }
    return totalCount;
  }

  Future<void> _sendOrder() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (widget.cartItems.isEmpty) {
      _showMessage("Your cart is empty");
      return;
    }

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      _showMessage("Please fill all details!");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _orderService.createOrder(
        name: name,
        phone: phone,
        address: address,
        cartItems: widget.cartItems,
      );

      widget.onOrderCompleted();

      if (!mounted) return;
      _showMessage("Order Sent Successfully!");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage("Order failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const textColor = Color(0xFF2D1D15);
    const buttonTextColor = Color(0xFF4A4A4A);
    const inputBgColor = Color(0xFFFFFFFF);
    final cartCount = _getCartCount();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: goldColor,
                        size: 28,
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                    ),
                    const Text(
                      "Checkout",
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: goldColor,
                            size: 26,
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                cartCount > 99 ? "99+" : "$cartCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _CheckoutInputRow(
                      label: "Name :",
                      controller: _nameController,
                      inputBgColor: inputBgColor,
                    ),
                    const SizedBox(height: 20),
                    _CheckoutInputRow(
                      label: "Phone :",
                      controller: _phoneController,
                      inputBgColor: inputBgColor,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 80,
                            child: Text(
                              "Address :",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _addressController,
                              enabled: !_isSubmitting,
                              maxLines: 4,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: _isSubmitting ? null : _sendOrder,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD4AF37),
                          Color(0xFFF7F1E3),
                          Color(0xFFD4AF37),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: buttonTextColor,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Send Order",
                              style: TextStyle(
                                color: buttonTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class _CheckoutInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color inputBgColor;
  final TextInputType keyboardType;

  const _CheckoutInputRow({
    required this.label,
    required this.controller,
    required this.inputBgColor,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF2D1D15);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: inputBgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
