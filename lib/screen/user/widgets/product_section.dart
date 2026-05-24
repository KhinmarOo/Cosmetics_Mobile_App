import 'package:flutter/material.dart';
import '../../../components/add_card_button.dart';
import '../product_details.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeMore; 
  final List<Map<String, String>> favoritedProducts; 
  final Function(Map<String, String>) onFavoriteToggle;
  
  // ⭐ အဓိကပြင်ဆင်ချက် - home.dart နဲ့ ကိုက်ညီအောင် Parameter ၂ ခု (Map, int) လက်ခံဖို့ သေချာပြောင်းလိုက်ပါတယ်
  final Function(Map<String, dynamic>, int) onAddToCart; 

  const ProductSection({
    super.key, 
    required this.title,
    this.onSeeMore,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart, // <--- ပါဝင်ပြီးသားအတိုင်း ထားရှိပါသည်
  });

  @override
  Widget build(BuildContext context) {
    // နမူနာ ထည့်သွင်းထားသော ပစ္စည်းများစာရင်း
    final List<Map<String, String>> dummyProducts = [
      {
        "name": "Romand Zero Matte Lipstick",
        "price": "32,000 MMK",
        "brand": "Rom&nd"
      },
      {
        "name": "Novo Cushion Cream",
        "price": "14,500 MMK",
        "brand": "Novo"
      },
      {
        "name": "Cutapro Sunscreen SPF 50++",
        "price": "32,000 MMK",
        "brand": "CutaPro"
      },
      {
        "name": "Maybelline Liquid Foundation",
        "price": "25,000 MMK",
        "brand": "Maybelline"
      },
    ];

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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D1D15)),
              ),
              if (title == "Popular Products")
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text("See More..", style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: dummyProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final product = dummyProducts[index];
              
              // ၎င်းပစ္စည်းကို အသဲပေးထားပြီးပြီလား စစ်ဆေးခြင်း
              final bool isFav = favoritedProducts.any((p) => p["name"] == product["name"]);
              return GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => 
                    ProductDetailsScreen(
                      product: product,
                      onAddToCart: (prod, qty) {
                          onAddToCart(Map<String, dynamic>.from(prod), qty);
                        },
                    ))
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            onFavoriteToggle(product); 
                          },
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                            size: 20, 
                            color: isFav ? const Color(0xFFE6B31E) : const Color(0xFFC7A17A),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Icon(Icons.spa_outlined, size: 50, color: Color(0xFFC7A17A)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product["name"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product["price"]!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D1D15)),
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
                                      
                                      // ⭐ ဗဟိုကို အရေအတွက် ၁ ခုနဲ့အတူ ပေးပို့လိုက်ပါတယ်
                                      onAddToCart(Map<String, dynamic>.from(product), 1);

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
    );
  }
}