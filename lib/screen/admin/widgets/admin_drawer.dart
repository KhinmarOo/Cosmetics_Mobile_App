import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDrawer extends StatelessWidget {
  final String activeTitle;

  const AdminDrawer({super.key, required this.activeTitle});

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _lightGoldColor = Color(0xFFF7F1E3);
  static const Color _darkTextColor = Color(0xFF2D1D15);

  static const Map<String, String> _routes = {
    "Dashboard": "/admin",
    "Category": "/admin/category",
    "Products": "/admin/products",
    "Offer Lists": "/admin/offers",
    "Order": "/admin/orders",
    "Customer Lists": "/admin/users",
  };

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 210,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_goldColor, _lightGoldColor, _goldColor],
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/cosmetic_logo.png',
                width: 86,
                height: 86,
                fit: BoxFit.contain,
              ),
            ),
          ),
          _drawerItem(context, Icons.home_filled, "Dashboard"),
          _drawerItem(context, Icons.category_outlined, "Category"),
          _drawerItem(context, Icons.grid_view, "Products"),
          _drawerItem(context, Icons.local_offer_outlined, "Offer Lists"),
          _drawerItem(context, Icons.shopping_cart_outlined, "Order"),
          _drawerItem(context, Icons.people_outline, "Customer Lists"),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: _darkTextColor),
            title: const Text(
              "Logout",
              style: TextStyle(color: _darkTextColor),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title) {
    final isActive = activeTitle == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 44,
          constraints: const BoxConstraints(maxWidth: 230),
          decoration: BoxDecoration(
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0xFFD4AF37),
                      Color(0xFFF7F1E3),
                      Color(0xFFD4AF37),
                    ],
                  )
                : null,
          ),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            leading: Icon(icon, color: _darkTextColor, size: 21),
            title: Text(title, style: const TextStyle(color: _darkTextColor)),
            onTap: () {
              Navigator.pop(context);
              if (isActive) return;

              final route = _routes[title];
              if (route == null) return;
              Navigator.pushReplacementNamed(context, route);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
