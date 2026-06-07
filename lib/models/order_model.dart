class OrderModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final int totalAmount;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.phone,
    required this.address,
    required this.totalAmount,
    this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    List<OrderItemModel> items = const [],
  }) {
    return OrderModel(
      id: map['order_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      name: map['order_name']?.toString() ?? '',
      phone: map['order_phone']?.toString() ?? '',
      address: map['order_address']?.toString() ?? '',
      totalAmount: (map['total_amount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      items: items,
    );
  }

  Map<String, dynamic> toInsertMap() {
    final data = {
      'order_name': name,
      'order_phone': phone,
      'order_address': address,
      'total_amount': totalAmount,
    };

    if (id.isNotEmpty) {
      data['order_id'] = id;
    }

    if (userId.isNotEmpty) {
      data['user_id'] = userId;
    }

    return data;
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String productImage;
  final int productPrice;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.quantity,
  });

  int get lineTotal => productPrice * quantity;
}
