import 'package:flutter/material.dart';
import '../../components/add_card_button.dart';

class WishlistScreen extends StatelessWidget {
  final List<Map<String, String>> favoritedProducts;
  final Function(Map<String, String>) onFavoriteToggle;

  const WishlistScreen({
    super.key,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFC7A17A);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Figma နောက်ခံ ပန်းဆီရောင်ဖျော့
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header - Wishlist ခေါင်းစဉ်
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: goldColor, size: 20),
                    onPressed: () {},
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

            // အသဲပေးထားသော ပစ္စည်းများပြသမည့်အပိုင်း
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final product = favoritedProducts[index];

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9F5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: goldColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ညာဘက်အပေါ်ထောင့်ရှိ အပြည့်ဖြည့်ထားသော အသဲပုံခလုတ်
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => onFavoriteToggle(product), // နှိပ်လိုက်လျှင် ချက်ချင်းစာရင်းထဲမှ ပျောက်မည်
                                  child: const Icon(
                                    Icons.favorite_rounded, // အသဲပုံ အပြည့်
                                    size: 20,
                                    color: Colors.orange, // လိမ္မော်ရောင်/ရွှေရောင် အသဲပုံ
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Icon(Icons.spa_outlined, size: 55, color: goldColor),
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
                              AddCardButton(onTap: () {}),
                            ],
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