
import 'package:flutter/material.dart';
import 'package:project/screen/user/product_details.dart';
import '../../components/add_card_button.dart';
import 'cart.dart';

class ProductScreen extends StatefulWidget {
  final List<Map<String, String>> favoritedProducts;
  final Function(Map<String, String>) onFavoriteToggle;
  
  // ⭐ ပြင်ဆင်ပြီး - MainLayout ကဲ့သို့ Parameter နှစ်ခု (product, quantity) လက်ခံရန် ပြောင်းလဲလိုက်ပါတယ်
  final Function(Map<String, dynamic>, int) onAddToCart;
  
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity;

  const ProductScreen({
    super.key,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart, // <--- မူလအတိုင်း ထားရှိပါမည်
    required this.cartItems,      
    required this.onUpdateQuantity,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _currentNavIndex = 1;

  final List<Map<String, String>> allProducts = [
    {"name": "Novo Cushion Cream", "price": "14,500 MMK"},
    {"name": "Neon Resplendent Light Lipstick", "price": "9,700 MMK"},
    {"name": "Novo Waterproof Eyebrow", "price": "7,000 MMK"},
    {"name": "Novo Mushroom Head Cushion", "price": "6,200 MMK"},
    {"name": "Romand See-Through Matte Tint", "price": "32,000 MMK"},
    {"name": "Romand Juicy Lasting Tint", "price": "32,000 MMK"},
    {"name": "Romand Dewyful Water Tint", "price": "35,000 MMK"},
    {"name": "Cutapro Sensitive Moisturizer 120 ml", "price": "35,000 MMK"},
    {"name": "Cutapro Alcohol Moisturizer 150 ml", "price": "35,000 MMK"},
    {"name": "Cutapro Sunscreen SPF 50++ 30 ml", "price": "32,000 MMK"},
    {"name": "Cutapro Vitamin C 30 ml", "price": "43,000 MMK"},
    {"name": "Fraijour Retin-Collagen Cleanser 250g", "price": "31,200 MMK"},
    {"name": "Fraijour Jelly Ice Cream 100m", "price": "39,000 MMK"},
    {"name": "Fraijour Wormwood Calming Toner 500ml", "price": "43,100 MMK"},
    {"name": "Vaseline Gluta-Hya Radiance Perfector Lotion", "price": "39,000 MMK"},
    {"name": "Vaseline Flawless Glow Body Serum", "price": "31,500 MMK"},
    {"name": "Maybelline Fit Me Matte Foundation 30 ml", "price": "85,000 MMK"},
    {"name": "Maybelline Lasting Fix Loose Powder", "price": "52,000 MMK"},
    {"name": "Maybelline Color Sensational Creamy Matte Lipstick", "price": "21,000 MMK"},
    {"name": "Maybelline Sky High Waterproof Mascara", "price": "36,500 MMK"},
  ];

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), 
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
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: goldColor, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: goldColor),
                    onPressed: () {},
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
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Color(0xFF2D1D15), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF2D1D15)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 100),
                itemCount: allProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,          
                  childAspectRatio: 0.68,      
                  crossAxisSpacing: 12,        
                  mainAxisSpacing: 12,         
                ),
                itemBuilder: (context, index) {
                  final product = allProducts[index];
                  final bool isFav = widget.favoritedProducts.any((p) => p["name"] == product["name"]);
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> ProductDetailsScreen(
                          product: product,
                          // ⭐ ပြင်ဆင်ပြီး - Detail Screen ဘက်က Argument အမျိုးအစားနဲ့ ကွက်တိ ကိုက်ညီသွားအောင် ပြောင်းလဲပေးထားပါတယ်
                          onAddToCart: (prod, qty) {
                            widget.onAddToCart(Map<String, dynamic>.from(prod), qty);
                          },
                        ))
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: goldColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: (){
                                widget.onFavoriteToggle(product);
                              },
                              child: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                                size: 20, 
                                color: isFav ? const Color(0xFFE6B31E) : goldColor,
                              ),
                            ),
                          ),
                          
                          const Expanded(
                            child: Center(
                              child: Icon(
                                Icons.spa_outlined, 
                                size: 55, 
                                color: goldColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            product["name"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D1D15),
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            product["price"]!,
                            style: const TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF2D1D15),
                            ),
                          ),
                          const SizedBox(height: 8),

                          AddCardButton(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFFFFFCF2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    title: const Text(
                                      "Add to Cart?",
                                      style: TextStyle(color: Color(0xFF2D1D15), fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    content: Text(
                                      "Do you want to add '${product["name"]}' to your shopping cart?",
                                      style: const TextStyle(color: Color(0xFF2D1D15), fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); 
                                        },
                                        child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); 
                                          
                                          // ⭐ ပြင်ဆင်ပြီး - Map ပြောင်းလဲခြင်းနှင့် အရေအတွက် 1 ကို လှမ်းထည့်တာ အခုဆို အနီရောင် ပျောက်သွားပါပြီဗျာ
                                          widget.onAddToCart(Map<String, dynamic>.from(product), 1);
                                          
                                        },
                                        child: const Text("Add", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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