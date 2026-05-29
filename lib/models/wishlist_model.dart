class WishlistModel {
  final String id;
  final String userId;
  final String productId;
  final DateTime? createdAt;

  const WishlistModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
  });

  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      id: map['wishlist_id']?.toString() ?? map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      productId: map['pro_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {'user_id': userId, 'pro_id': productId};
  }
}
