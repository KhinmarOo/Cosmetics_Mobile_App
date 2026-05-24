
import 'package:flutter/material.dart';
import 'home.dart';
import 'product.dart';
import '../../components/bottom_nav_bar.dart';
import './wishlist.dart';
import 'cart.dart';
import 'account.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // လက်ရှိ ရောက်နေတဲ့ page index ကို ဗဟိုကနေ ထိန်းချုပ်ရန် ကြေညာခြင်း
  int _currentIndex = 0; 

  // ၁။ State ထဲမှာ Cart List ကြေညာခြင်း
  List<Map<String, dynamic>> _cartProducts = [];

  // ၂။ Add To Cart နှိပ်ရင် ပစ္စည်းအသစ်ထည့်မယ့် သို့မဟုတ် ရှိပြီးသားဆိုရင် အရေအတွက်တိုးမယ့် Function
  void _addToCart(Map<String, dynamic> product, int quantity) {
    setState(() {
      // Cart ထဲမှာ ပစ္စည်းအမည် တူတာ ရှိ၊ မရှိ အရင်စစ်သည်
      final index = _cartProducts.indexWhere((item) => item["name"] == product["name"]);
      if (index >= 0) {
        // ရှိပြီးသားဆိုရင် အရေအတွက်ပဲ ပေါင်းထည့်မည်
        _cartProducts[index]["quantity"] = (_cartProducts[index]["quantity"] as int) + quantity;
      } else {
        // မရှိသေးရင် အသစ်ထည့်မည်
        _cartProducts.add({
          "name": product["name"],
          "price": product["price"],
          "quantity": quantity,
        });
      }
    });
  }

  // ၃။ Cart Screen ထဲကနေ + / - နှိပ်ရင် အရေအတွက်ကို ပြင်ဆင်မယ့် Function
  void _updateCartQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartProducts.removeAt(index); // အရေအတွက် ၀ ဖြစ်သွားရင် Cart ထဲမှ ဖယ်ထုတ်ခြင်း
      } else {
        _cartProducts[index]["quantity"] = newQuantity; // အရေအတွက် တိုး/လျော့ခြင်း
      }
    });
  }

  // အသဲပေးထားသော ပစ္စည်းများကိုသာ သိမ်းဆည်းမည့် ဗဟို List
  final List<Map<String, String>> _favoritedProducts = [];

  // အသဲပေး/ဖြုတ်ခြင်း လုပ်ဆောင်ချက် (Toggle Function)
  void _toggleFavorite(Map<String, String> product) {
    setState(() {
      // ပစ္စည်းအမည်တူ ရှိ/မရှိ စစ်ဆေးခြင်း
      bool isExist = _favoritedProducts.any((p) => p["name"] == product["name"]);
      if (isExist) {
        _favoritedProducts.removeWhere((p) => p["name"] == product["name"]); // ရှိပြီးသားဆိုရင် ဖြုတ်ပစ်မယ်
      } else {
        _favoritedProducts.add(product); // မရှိသေးရင် အသဲစာရင်းထဲ ထည့်မယ်
      }
    });
  }
  
  // 💡 စာမျက်နှာများကို Method အနေနဲ့ တည်ဆောက်ထားခြင်း
  List<Widget> _pages() {
    return [
      HomeScreen(
        favoritedProducts: _favoritedProducts,
        onFavoriteToggle: _toggleFavorite,
        // ⭐ အဆင်ပြေအောင် Type ကို အသေအချာ ညှိပေးထားပါတယ်
        onAddToCart: (Map<String, dynamic> product, int quantity) {
          _addToCart(product, quantity); 
        },
        onSeeMore: () {
          setState(() {
            _currentIndex = 1; 
          });
        },
      ),
      ProductScreen(
        favoritedProducts: _favoritedProducts,
        onFavoriteToggle: _toggleFavorite,
        onAddToCart: _addToCart, // 👈 အခုလို တိုက်ရိုက် တန်းပေးလိုက်ရုံပါပဲဗျာ!
        cartItems: _cartProducts,
        onUpdateQuantity: _updateCartQuantity,
      ),
      WishlistScreen(
        favoritedProducts: _favoritedProducts,
        onFavoriteToggle: _toggleFavorite,
      ),
      CartScreen(
        cartItems: _cartProducts,
        onUpdateQuantity: _updateCartQuantity,
      ),
      const AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        // ⭐ ပြင်ဆင်ပြီး - အောက်က _pages အနောက်မှာ ကွင်းစကွင်းပိတ် () လေး ထည့်ပေးလိုက်ပါပြီ။ ဒါဆို MainLayout ထဲက နီတာတွေ အကုန်ပျောက်ပါပြီခင်ဗျာ။
        children: _pages(), 
      ),
      
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; 
          });
        },
      ),
    );
  }
}