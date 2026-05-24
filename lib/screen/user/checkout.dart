import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Form အချက်အလက်များကို ထိန်းချုပ်ရန် Controller များ
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Cart ထဲက ပစ္စည်းအရေအတွက် စုစုပေါင်းကို တွက်ချက်ပေးမည့် Function
  int _getCartCount() {
    int totalCount = 0;
    for (var item in widget.cartItems) {
      totalCount += (item["quantity"] as int? ?? 0);
    }
    return totalCount;
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color textColor = Color(0xFF2D1D15);
    const Color inputBgColor = Color(0xFFFFFFFF); // ပုံပါအတိုင်း ဖျော့တော့သော ပန်းရောင်သန်းသည့် Input Background
    int cartCount = _getCartCount();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ၁။ Header Section (Back Arrow, Title & Cart Badge)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: goldColor, size: 28),
                      onPressed: () {
                        Navigator.pop(context); // ခလုတ်နှိပ်လျှင် ရှေ့စာမျက်နှာသို့ ပြန်သွားရန်
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
                    // Shopping Cart Badge
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: goldColor, size: 26),
                          onPressed: () {},
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
                                '$cartCount',
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

              // ၂။ Input Form Fields Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // --- Name Input ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            "Name :",
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(12),
                              // border: Border.all(color: goldColor.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]
                            ),
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Phone Input ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            "Phone :",
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(12),
                              // border: Border.all(color: goldColor.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Address Input ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: 80,
                            child: Text(
                              "Address :",
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 100, // လိပ်စာအတွက် Box ကို ပိုကြီးအောင် သတ်မှတ်ခြင်း
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(12),
                              // border: Border.all(color: goldColor.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]
                            ),
                            child: TextField(
                              controller: _addressController,
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

              // ၃။ Send Order Button (Gradient Style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {
                    // အော်ဒါတင်ခြင်း အောင်မြင်ကြောင်း လုပ်ဆောင်ချက် ရေးရန်နေရာ
                    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all details!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order Sent Successfully!")),
                      );
                    }
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE6B31E), 
                          Color(0xFFF7F1E3),
                          Color(0xFFE6B31E), 
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Send Order",
                        style: TextStyle(
                          color: textColor,
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