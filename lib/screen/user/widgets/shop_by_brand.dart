import 'package:flutter/material.dart';

class ShopByBrandSection extends StatelessWidget {
  const ShopByBrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    // ညွှန်ကြားထားသည့် Brand ၆ ခုစာရင်း
    final List<String> brands = [
      "CutaPro",
      "Rom&nd",
      "Novo",
      "Fraijour",
      "Maybelline",
      "Vaseline"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "SHOP BY BRAND",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1D15),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            // ၃၆၀ ပတ်ချာလည် အနန္တ ဆွဲလို့ရစေရန် itemCount ကို အများကြီး ပေးထားခြင်းဖြစ်ပါတယ်
            itemCount: 10000, 
            itemBuilder: (context, index) {
              // ပတ်ချာလည် လည်ပတ်နိုင်ရန် % ခံ၍ အကြွင်းရှာခြင်း
              final brandName = brands[index % brands.length];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    // ရွှေရောင် Gradient ပါသော အဝိုင်းပုံစံ Brand Button
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFE6B31E), // ရွှေဝါရောင် ဖျော့
                            Color(0xFFF7F1E3),
                            Color(0xFFE6B31E),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          brandName.substring(0, index % brands.length == 0 ? 4 : 3), // အတိုကောက်စာသားပြရန်
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1D15),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      brandName,
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}