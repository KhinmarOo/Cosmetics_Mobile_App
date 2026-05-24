import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  // User Profile ကို ဆွဲထုတ်မယ့် Function
  Future<UserModel> getUserProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('users')
        .select()
        .eq('user_id', userId)
        .single();
    
    return UserModel.fromJson(response);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}