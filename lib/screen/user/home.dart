
import 'dart:async';
import 'package:flutter/material.dart';
import '../../components/bottom_nav_bar.dart';
import 'widgets/shop_by_brand.dart';
import 'widgets/product_section.dart';
import './product.dart';

class HomeScreen extends StatefulWidget {
  // MainLayout ကနေ လှမ်းပို့မယ့် Parameter များကို လက်ခံရန် သတ်မှတ်ခြင်း
  final VoidCallback? onSeeMore; // <--- MainLayout ဘက်က နာမည်နှင့် ကိုက်ညီအောင် ပြောင်းထားပါသည်
  final List<Map<String, String>> favoritedProducts; 
  final Function(Map<String, String>) onFavoriteToggle;
  final Function(Map<String, dynamic>, int) onAddToCart;

  const HomeScreen({
    super.key, 
    this.onSeeMore, // <--- ပြင်ဆင်ပြီး
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  // နမူနာ Promotion Banner ပုံများ
  final List<String> _promoBanners = [
    'assets/img/banner1.png',
    'assets/img/banner2.png',
    'assets/img/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    // ၃ စက္ကန့်တစ်ခါ Banner အလိုအလျောက် ပြောင်းရန် Timer ပတ်ခြင်း
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentBannerPage < _promoBanners.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (က) Top Header Section: Logo & Cart Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        // Image.asset('assets/img/logo_shield.png', width: 35, height: 35),
                        SizedBox(width: 8),
                        Text(
                          "Beauty with me.",
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

              // (ခ) Search Bar
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
              const SizedBox(height: 20),

              // (ဂ) Auto Slider Promotion Card (3 Seconds)
              Container(
                height: 140,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: PageView.builder(
                  controller: _bannerController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerPage = index;
                    });
                  },
                  itemCount: _promoBanners.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE3D2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: goldColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Beaut with me.",
                                    style: TextStyle(color: Color(0xFF2D1D15), fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Authentic Skincare Collections",
                                    style: TextStyle(color: Colors.black54, fontSize: 11),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "100 %",
                                    style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(Icons.auto_awesome, size: 60, color: goldColor.withOpacity(0.6)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // (ဃ) Shop By Brand Section
              const ShopByBrandSection(),
              const SizedBox(height: 10),

              // (င) New Products Section (ဒေတာများကို widget. မှတစ်ဆင့် လှမ်းပို့ပေးလိုက်ပါသည်)
              ProductSection(
                title: "New Products",
                favoritedProducts: widget.favoritedProducts,
                onFavoriteToggle: widget.onFavoriteToggle,
                onAddToCart: (prod, qty) {
                  widget.onAddToCart(prod, qty);
                },
              ),
              const SizedBox(height: 10),

              // (စ) Popular Products Section (See More နှင့် အသဲပေးဒေတာများ အားလုံး ချိတ်ဆက်ပြီး)
              ProductSection(
                title: "Popular Products",
                onSeeMore: widget.onSeeMore, // <--- ပြင်ဆင်ပြီး
                favoritedProducts: widget.favoritedProducts,
                onFavoriteToggle: widget.onFavoriteToggle,
                onAddToCart: (prod, qty) {
                  widget.onAddToCart(prod, qty);
                },
              ),
              
              const SizedBox(height: 100), // Nav Bar ကွယ်မသွားစေရန်
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }
}