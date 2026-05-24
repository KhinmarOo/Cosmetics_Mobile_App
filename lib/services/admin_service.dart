import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final _supabase = Supabase.instance.client;

  // Dashboard ကိန်းဂဏန်းတွေအတွက်
  Future<Map<String, int>> getDashboardStats() async {
    final ordersCount = await _supabase.from('orders').count();
    final usersCount = await _supabase.from('profiles').count();
    // Income အတွက် logic ထည့်ရန်...
    return {'orders': ordersCount, 'users': usersCount};
  }
}