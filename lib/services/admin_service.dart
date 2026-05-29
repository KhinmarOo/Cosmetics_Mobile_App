import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final _supabase = Supabase.instance.client;

  Future<DashboardStats> getDashboardStats() async {
    final ordersCount = await _supabase.from('orders').count(CountOption.exact);
    final usersCount = await _supabase.from('users').count(CountOption.exact);
    final incomeRows = await _supabase.from('orders').select('total_amount');

    var totalIncome = 0;
    for (final item in (incomeRows as List<dynamic>)) {
      final row = item as Map<String, dynamic>;
      totalIncome += (row['total_amount'] as num?)?.toInt() ?? 0;
    }

    return DashboardStats(
      totalOrders: ordersCount,
      totalUsers: usersCount,
      totalIncome: totalIncome,
    );
  }
}

class DashboardStats {
  final int totalOrders;
  final int totalUsers;
  final int totalIncome;

  const DashboardStats({
    required this.totalOrders,
    required this.totalUsers,
    required this.totalIncome,
  });
}
