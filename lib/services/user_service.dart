import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<UserModel> getUserProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('users')
        .select()
        .eq('user_id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> getUsers() async {
    final response = await _supabase
        .from('users')
        .select('user_id, user_name, user_email, user_phone, user_role')
        .order('user_name', ascending: true);

    return (response as List<dynamic>)
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createAdminUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    final createdUser = response.user;

    if (createdUser == null) {
      throw const AuthException("Customer account was not created");
    }

    final user = UserModel(
      id: createdUser.id,
      name: name,
      email: email,
      phone: phone,
      role: 'admin',
    );

    await _supabase.from('users').insert(user.toInsertMap());
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    final response = await _supabase
        .from('users')
        .update({
          'user_name': name,
          'user_email': email,
          'user_phone': phone,
          'user_role': role,
        })
        .eq('user_id', id)
        .select('user_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception("User was not updated. Check user id or update policy.");
    }
  }

  Future<void> updateCurrentUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      throw const AuthException("Please login again to update your profile");
    }

    final currentEmail = authUser.email?.trim().toLowerCase() ?? '';
    final newEmail = email.trim().toLowerCase();

    if (newEmail.isNotEmpty && newEmail != currentEmail) {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
    }

    final response = await _supabase
        .from('users')
        .update({
          'user_name': name.trim(),
          'user_email': email.trim(),
          'user_phone': phone.trim(),
        })
        .eq('user_id', authUser.id)
        .select('user_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception("Profile was not updated. Check user update policy.");
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await _supabase
        .from('users')
        .delete()
        .eq('user_id', id)
        .select('user_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception("User was not deleted. Check user id or delete policy.");
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
