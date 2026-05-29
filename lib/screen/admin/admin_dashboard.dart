import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/dashboard_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String activeMenu;

  const AdminDashboardScreen({super.key, this.activeMenu = "Dashboard"});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _lightGoldColor = Color(0xFFF7F1E3);
  final AdminService _adminService = AdminService();
  late final String selectedMenu;
  late Future<DashboardStats> _dashboardStatsFuture;

  @override
  void initState() {
    super.initState();
    selectedMenu = widget.activeMenu;
    _dashboardStatsFuture = _adminService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      appBar: AppBar(
        title: Text(selectedMenu),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [_goldColor, _lightGoldColor, _goldColor],
            ),
          ),
        ),
      ),
      drawer: const AdminDrawer(activeTitle: "Dashboard"),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<DashboardStats>(
        future: _dashboardStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load dashboard: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final stats =
              snapshot.data ??
              const DashboardStats(
                totalOrders: 0,
                totalUsers: 0,
                totalIncome: 0,
              );

          return RefreshIndicator(
            color: _goldColor,
            onRefresh: _refreshDashboardStats,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                DashboardCard(
                  title: "Total Orders",
                  value: _formatNumber(stats.totalOrders),
                  icon: Icons.shopping_basket,
                  iconBgColor: const Color(0xFFFCE3D2),
                ),
                DashboardCard(
                  title: "Total Users",
                  value: _formatNumber(stats.totalUsers),
                  icon: Icons.group,
                  iconBgColor: const Color(0xFFF0E9D6),
                ),
                DashboardCard(
                  title: "Income",
                  value: "${_formatNumber(stats.totalIncome)} MMK",
                  icon: Icons.attach_money,
                  iconBgColor: const Color(0xFFE8F0E9),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshDashboardStats() async {
    final statsFuture = _adminService.getDashboardStats();
    setState(() => _dashboardStatsFuture = statsFuture);
    await statsFuture;
  }

  String _formatNumber(int value) {
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.toString().replaceAllMapped(reg, (match) => '${match[1]},');
  }
}
