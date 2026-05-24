import 'package:flutter/material.dart';
import 'widgets/dashboard_card.dart';
import './category.dart';
import 'product.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedMenu = "Dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedMenu),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Admin"),
              accountEmail: Text("admin@beautywithme.com"),
              decoration: BoxDecoration(color: Color(0xFFD4AF37)),
            ),
            _sidebarItem(Icons.home_filled, "Dashboard", const AdminDashboardScreen()), // Dashboard ကို ပြန်သွားမယ်
            _sidebarItem(Icons.category_outlined, "Category", const CategoryScreen()),
            _sidebarItem(Icons.grid_view, "Products", const AddProductScreen()),
            // _sidebarItem(Icons.shopping_cart_outlined, "Order", const OrderScreen()),
            // _sidebarItem(Icons.people_outline, "User List", const UserListScreen()),
            // const Divider(),
            // _sidebarItem(Icons.logout, "Logout", const LoginScreen()),
          ],
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _sidebarItem(IconData icon, String title, Widget destinationPage) { // destinationPage ကို ထည့်လိုက်ပါ
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Drawer ကို အရင်ပိတ်ပါ
        if (title == "Dashboard") {
          // Dashboard မှာဆိုရင်တော့ Home ကို ပြန်သွားမလား စဉ်းစားပါ
        } else {
          // တခြား page ဆိုရင် Navigator နဲ့ သွားပါ
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      },
    );
  }

  Widget _buildContent() {
    if (selectedMenu == "Dashboard") {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            DashboardCard(title: "Total Orders", value: "800", icon: Icons.shopping_basket, iconBgColor: Color(0xFFFCE3D2)),
            DashboardCard(title: "Total Users", value: "900", icon: Icons.group, iconBgColor: Color(0xFFF0E9D6)),
            DashboardCard(title: "Income", value: "535,500", icon: Icons.attach_money, iconBgColor: Color(0xFFE8F0E9)),
          ],
        ),
      );
    } else {
      return Center(child: Text("$selectedMenu အပိုင်းကို နောက်မှ ဆက်ရေးမယ်"));
    }
  }
}