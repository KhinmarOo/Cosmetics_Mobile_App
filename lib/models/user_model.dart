class UserModel{
  final String id;
  final String name;
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone
  });

  factory UserModel.fromJson(Map<String, dynamic>json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['user_name'] ?? '',
      email: json['user_email'] ?? '',
      phone: json['user_phone'] ?? '',
    );
  }
}