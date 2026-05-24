import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, String> product;
  final Function(Map<String, dynamic>, int) onAddToCart;

  const ProductDetailsScreen({super.key, required this.product,required this.onAddToCart,});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1; // လက်ရှိ အရေအတွက်

  // စျေးနှုန်းစာသား "32,000 MMK" မှ ကိန်းဂဏန်း "32000" အဖြစ် ပြောင်းလဲပေးမယ့် Helper Function
  int _parsePrice(String priceStr) {
    // ကော်မာများနှင့် စာသားများကို ဖယ်ထုတ်ပြီး ဂဏန်းသီးသန့် ယူခြင်း
    final cleanString = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  // ရလာတဲ့ စျေးနှုန်းကိန်းဂဏန်းကို "32,000 MMK" ပုံစံ စာသားပြန်ပြောင်းပေးမယ့် Helper Function
  String _formatPrice(int price) {
    // Number format အတွက် ရိုးရှင်းသော String manipulation သုံးထားခြင်း
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String Function(Match) mathFunc = (Match match) => '${match[1]},';
    final String formatted = price.toString().replaceAllMapped(reg, mathFunc);
    return "$formatted MMK";
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color darkBrown = Color(0xFF4A4A4A);

    // ၁။ မူရင်း စျေးနှုန်းကို ဂဏန်းပြောင်းလဲခြင်း
    final int basePrice = _parsePrice(widget.product["price"] ?? "0");
    // ၂။ အရေအတွက်နှင့် မူရင်းစျေးနှုန်း မြှောက်ပြီး စုစုပေါင်း金額ကို တွက်ချက်ခြင်း
    final int totalPrice = basePrice * quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Image section & Back Button
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F2), 
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.spa_outlined,
                          size: 100,
                          color: goldColor,
                        ),
                      ),
                    ),
                    // Back Button
                    Positioned(
                      top: 15,
                      left: 15,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.4),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Product Information Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          widget.product["name"] ?? "Product Name",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Price and Quantity Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ဤနေရာတွင် ပစ္စည်းတစ်ခုချင်းစီ၏ မူရင်းစျေးနှုန်းကို ပြသထားမည်ဖြစ်သည်
                            Text(
                              widget.product["price"] ?? "0 MMK",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
                              ),
                            ),
                            
                            // Quantity Counter (- 1 +)
                            Row(
                              children: [
                                // ➖ နှုတ်ရန် ခလုတ်
                                GestureDetector(
                                  onTap: () {
                                    if (quantity > 1) {
                                      setState(() {
                                        quantity--; // အရေအတွက် လျှော့ချပြီး UI ကို update လုပ်ခြင်း
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: goldColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.remove, size: 16, color: Colors.white),
                                  ),
                                ),
                                
                                // လက်ရှိ အရေအတွက် စာသားပြသမည့်နေရာ
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    "$quantity",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                
                                // ➕ တိုးရန် ခလုတ်
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      quantity++; // အရေအတွက် တိုးမြှင့်ပြီး UI ကို update လုပ်ခြင်း
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: goldColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Product Description
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
                          "In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum dolor sit amet...",
                          style: TextStyle(
                            fontSize: 13,
                            color: darkBrown.withOpacity(0.6),
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

            // 3. Bottom Sticky Bar (Total Price & Add To Cart Button)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ⭐ ပြင်ဆင်ပြီး - Total Price နေရာတွင် မြှောက်ပြီးသား စုစုပေါင်းစျေးနှုန်းကို တိုက်ရိုက်ပြသခြင်း
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Total Price:",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          _formatPrice(totalPrice), // တွက်ချက်ပြီးသား ကိန်းဂဏန်းကို စာသားပြန်ပြောင်းပြီး ပြခြင်း
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    // Add To Cart Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF0F2),
                        foregroundColor: goldColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        widget.onAddToCart(widget.product,quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${widget.product["name"]} ($quantity) ခုကို Cart ထဲထည့်ပြီးပါပြီ။"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        // Cart ထဲကို ပစ္စည်းအမည်၊ တစ်ခုချင်းစျေး၊ အရေအတွက် (quantity) နဲ့ စုစုပေါင်းစျေး (totalPrice) တို့ လှမ်းပို့နိုင်ပါတယ်
                        // print("Added to cart: ${widget.product["name"]} x $quantity = $totalPrice MMK");
                      },
                      child: const Text(
                        "Add To Cart",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: goldColor),
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