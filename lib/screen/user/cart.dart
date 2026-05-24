import 'package:flutter/material.dart';
import './checkout.dart';

class CartScreen extends StatefulWidget {
  // MainLayout သို့မဟုတ် ဗဟို State စနစ်ကနေ Cart ဒေတာနဲ့ ၎င်းကို ပြင်ဆင်မယ့် လုပ်ဆောင်ချက်များကို လက်ခံခြင်း
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity; // (index, newQuantity)
  final VoidCallback? onOrderPressed;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    this.onOrderPressed,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // စျေးနှုန်းစာသား "32,000 MMK" မှ ကိန်းဂဏန်း "32000" သို့ ပြောင်းပေးသော Helper
  int _parsePrice(String priceStr) {
    final cleanString = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  // ကိန်းဂဏန်းကို "149,000 MMK" ပုံစံ စာသားပြန်ပြောင်းပေးသော Helper
  String _formatPrice(int price) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String Function(Match) mathFunc = (Match match) => '${match[1]},';
    final String formatted = price.toString().replaceAllMapped(reg, mathFunc);
    return "$formatted MMK";
  }

  @override
  Widget build(BuildContext context) {

    const Color goldColor = Color(0xFFD4AF37);
    const Color darkBrown = Color(0xFF2D1D15);
    const Color bgColor = Color(0xFFFFFCF2);
    // ၁။ Cart ထဲက ပစ္စည်းအားလုံးရဲ့ စုစုပေါင်း တန်ဖိုးကို တွက်ချက်ခြင်း
    int totalAmount = 0;
    for (var item in widget.cartItems) {
      int price = _parsePrice(item["price"] ?? "0");
      int qty = item["quantity"] ?? 1;
      totalAmount += (price * qty);
    }

    // ၂။ Shopping Cart Icon ပေါ်က Badge အတွက် စုစုပေါင်း အရေအတွက် တွက်ချက်ခြင်း
    int totalCartBadgeCount = widget.cartItems.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // (A) Top Header - Back Button, Title & Cart Badge Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: goldColor, size: 20),
                        onPressed: () => Navigator.pop(context),
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
                  // Shopping Cart Icon with Red Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, color: goldColor, size: 28),
                      if (totalCartBadgeCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text(
                              "$totalCartBadgeCount",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // (B) Cart Items List Section
            Expanded(
              child: widget.cartItems.isEmpty
                  ? const Center(
                      child: Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        int qty = item["quantity"] ?? 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // ပစ္စည်းပုံပြရန်နေရာ
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.spa_outlined, color: goldColor),
                              ),
                              const SizedBox(width: 12),

                              // အမည်နှင့် စျေးနှုန်း
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: darkBrown),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["price"] ?? "",
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkBrown),
                                    ),
                                  ],
                                ),
                              ),

                              // ➖ / ➕ အရေအတွက် ထိန်းချုပ်ခလုတ်များ
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (qty > 1) {
                                        widget.onUpdateQuantity(index, qty - 1);
                                      } else {
                                        // ၁ အောက် လျော့သွားရင် Cart ထဲက ဖယ်ထုတ်ပစ်မယ့် Logic မျိုးလည်း ထပ်ထည့်နိုင်ပါတယ်
                                        widget.onUpdateQuantity(index, 0); 
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: goldColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.remove, size: 14, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      "$qty",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkBrown),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.onUpdateQuantity(index, qty + 1);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: goldColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // (C) Bottom Bill & Order Section
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
                  // Total Amount စာသားနှင့် တန်ဖိုး
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount :",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkBrown),
                      ),
                      Text(
                        _formatPrice(totalAmount), // တွက်ချက်ပြီးသား စုစုပေါင်းပမာဏ
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkBrown),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Order Button (Figma Gradient ဒီဇိုင်း)
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            cartItems: widget.cartItems, // 👈 လက်ရှိ Cart ထဲက ပစ္စည်းစာရင်းတွေကို ပို့ပေးလိုက်ပါတယ်
                          ),
                        ),
                      );
                    },
                      child: const Text(
                        "Order",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBrown),
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