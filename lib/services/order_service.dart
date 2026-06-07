import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  Future<List<OrderModel>> getOrders() async {
    final orderRows = await _fetchOrderRows();
    return _buildOrders(orderRows);
  }

  Future<List<OrderModel>> getCurrentUserOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException("Please login again to view order history");
    }

    final orderRows = await _fetchOrderRows(userId: userId);
    return _buildOrders(orderRows);
  }

  Future<List<Map<String, dynamic>>> _fetchOrderRows({String? userId}) async {
    var query = _supabase
        .from('orders')
        .select(
          'order_id, user_id, created_at, order_name, order_phone, order_address, total_amount',
        );

    if (userId != null && userId.isNotEmpty) {
      query = query.eq('user_id', userId);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<List<OrderModel>> _buildOrders(
    List<Map<String, dynamic>> orderRows,
  ) async {
    if (orderRows.isEmpty) {
      return [];
    }

    final orderIds = orderRows
        .map((order) => order['order_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final itemRows = await _getOrderItemRows(orderIds);
    final productMap = await _getProductMap(itemRows);
    final offerPriceMap = await _getOfferPriceMap(itemRows);
    final itemsByOrderId = <String, List<OrderItemModel>>{};

    for (final item in itemRows) {
      final orderId = item['order_id']?.toString() ?? '';
      final productId = item['pro_id']?.toString() ?? '';
      final product = productMap[productId];
      final productPrice = (product?['pro_price'] as num?)?.toDouble() ?? 0;
      final offerPrice = offerPriceMap[productId];

      final orderItem = OrderItemModel(
        id: item['ot_id']?.toString() ?? '',
        orderId: orderId,
        productId: productId,
        productName: product?['pro_name']?.toString() ?? 'Unknown Product',
        productImage: product?['pro_image']?.toString() ?? '',
        productPrice: _effectiveItemPrice(productPrice, offerPrice),
        quantity: (item['ot_qty'] as num?)?.toInt() ?? 1,
      );

      itemsByOrderId.putIfAbsent(orderId, () => []).add(orderItem);
    }

    return orderRows.map((order) {
      final orderId = order['order_id']?.toString() ?? '';
      return OrderModel.fromMap(order, items: itemsByOrderId[orderId] ?? []);
    }).toList();
  }

  Future<OrderModel> createOrder({
    required String name,
    required String phone,
    required String address,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception("Cart is empty");
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException("Please login again before placing an order");
    }

    final order = OrderModel(
      id: _createUuidV4(),
      userId: userId,
      name: name.trim(),
      phone: phone.trim(),
      address: address.trim(),
      totalAmount: _calculateTotalAmount(cartItems),
    );

    await _supabase.from('orders').insert(order.toInsertMap());

    final orderItems = cartItems.map((item) {
      return {
        'order_id': order.id,
        'pro_id': item['id']?.toString(),
        'ot_qty': item['quantity'] as int? ?? 1,
      };
    }).toList();

    await _supabase.from('order_items').insert(orderItems);

    return order;
  }

  Future<void> updateOrder({
    required String orderId,
    required String name,
    required String phone,
    required String address,
  }) async {
    final response = await _supabase
        .from('orders')
        .update({
          'order_name': name.trim(),
          'order_phone': phone.trim(),
          'order_address': address.trim(),
        })
        .eq('order_id', orderId)
        .select('order_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception(
        "Order was not updated. Check order id or update policy.",
      );
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _supabase.from('order_items').delete().eq('order_id', orderId);

    final response = await _supabase
        .from('orders')
        .delete()
        .eq('order_id', orderId)
        .select('order_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception(
        "Order was not deleted. Check order id or delete policy.",
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getOrderItemRows(
    List<String> orderIds,
  ) async {
    if (orderIds.isEmpty) return [];

    final response = await _supabase
        .from('order_items')
        .select('ot_id, order_id, pro_id, ot_qty')
        .inFilter('order_id', orderIds);

    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, Map<String, dynamic>>> _getProductMap(
    List<Map<String, dynamic>> orderItems,
  ) async {
    final productIds = orderItems
        .map((item) => item['pro_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (productIds.isEmpty) return {};

    final response = await _supabase
        .from('products')
        .select('pro_id, pro_name, pro_image, pro_price')
        .inFilter('pro_id', productIds);

    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return {for (final row in rows) row['pro_id']?.toString() ?? '': row};
  }

  Future<Map<String, double>> _getOfferPriceMap(
    List<Map<String, dynamic>> orderItems,
  ) async {
    final productIds = orderItems
        .map((item) => item['pro_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (productIds.isEmpty) return {};

    final response = await _supabase
        .from('offers')
        .select('pro_id, offer_price')
        .inFilter('pro_id', productIds);

    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return {
      for (final row in rows)
        row['pro_id']?.toString() ?? '':
            (row['offer_price'] as num?)?.toDouble() ?? 0,
    };
  }

  int _effectiveItemPrice(double productPrice, double? offerPrice) {
    if (offerPrice != null && offerPrice > 0 && offerPrice < productPrice) {
      return offerPrice.round();
    }

    return productPrice.round();
  }

  int _calculateTotalAmount(List<Map<String, dynamic>> cartItems) {
    var totalAmount = 0;

    for (final item in cartItems) {
      final price = _parsePrice(item['price']?.toString() ?? '0');
      final quantity = item['quantity'] as int? ?? 1;
      totalAmount += price * quantity;
    }

    return totalAmount;
  }

  int _parsePrice(String price) {
    final numericText = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericText) ?? 0;
  }

  String _createUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final parts = [
      bytes.sublist(0, 4).map(hex).join(),
      bytes.sublist(4, 6).map(hex).join(),
      bytes.sublist(6, 8).map(hex).join(),
      bytes.sublist(8, 10).map(hex).join(),
      bytes.sublist(10, 16).map(hex).join(),
    ];

    return parts.join('-');
  }
}
