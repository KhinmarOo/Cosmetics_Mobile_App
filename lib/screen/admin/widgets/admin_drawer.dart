import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/logout_confirm_dialog.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

class AdminDrawer extends StatefulWidget {
  final String activeTitle;

  const AdminDrawer({super.key, required this.activeTitle});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final UserService _userService = UserService();
  late final Future<UserModel> _userFuture;

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
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile();
  }

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
            child: FutureBuilder<UserModel>(
              future: _userFuture,
              builder: (context, snapshot) {
                final authUser = Supabase.instance.client.auth.currentUser;
                final user = snapshot.data;
                final userName = user?.name.trim().isNotEmpty == true
                    ? user!.name.trim()
                    : authUser?.email ?? "Admin";
                final userEmail = user?.email.trim().isNotEmpty == true
                    ? user!.email.trim()
                    : authUser?.email ?? "";

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/cosmetic_logo.png',
                        width: 82,
                        height: 82,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: _darkTextColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: _darkTextColor.withValues(alpha: 0.74),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
    final isActive = widget.activeTitle == title;

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
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => const LogoutConfirmDialog(),
    );

    if (shouldLogout != true || !context.mounted) return;

    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
