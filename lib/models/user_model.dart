class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['user_email']?.toString() ?? '';

    return UserModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['user_name']?.toString().trim().isNotEmpty == true
          ? json['user_name'].toString()
          : email,
      email: email,
      phone: json['user_phone']?.toString() ?? '',
      role: json['user_role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': id,
      'user_name': name,
      'user_email': email,
      'user_phone': phone,
      'user_role': role,
    };
  }
}
