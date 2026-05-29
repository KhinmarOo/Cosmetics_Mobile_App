class ProductModel {
  final String proId;
  final String proName;
  final String proImage;
  final double proPrice;
  final double? salePrice;
  final int proQty;
  final String proDescription;
  final String catId;
  final DateTime? createdAt;

  ProductModel({
    required this.proId,
    required this.proName,
    required this.proImage,
    required this.proPrice,
    this.salePrice,
    required this.proQty,
    required this.proDescription,
    required this.catId,
    this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      proId: map['pro_id'].toString(),
      proName: map['pro_name'] ?? '',
      proImage: map['pro_image'] ?? '',
      proPrice: (map['pro_price'] ?? 0).toDouble(),
      salePrice: (map['sale_price'] as num?)?.toDouble(),
      proQty: map['pro_qty'] ?? 0,
      proDescription: map['pro_description'] ?? '',
      catId: map['cat_id'].toString(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }

  ProductModel copyWith({double? salePrice}) {
    return ProductModel(
      proId: proId,
      proName: proName,
      proImage: proImage,
      proPrice: proPrice,
      salePrice: salePrice ?? this.salePrice,
      proQty: proQty,
      proDescription: proDescription,
      catId: catId,
      createdAt: createdAt,
    );
  }

  bool get hasSale =>
      salePrice != null && salePrice! > 0 && salePrice! < proPrice;

  double get effectivePrice => hasSale ? salePrice! : proPrice;

  String get displayPrice {
    return "${_formatPrice(proPrice)} MMK";
  }

  String get displaySalePrice {
    return "${_formatPrice(effectivePrice)} MMK";
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.round().toString();
    }

    return price.toStringAsFixed(2);
  }

  Map<String, dynamic> toCartItem(int quantity) {
    return {
      'id': proId,
      'name': proName,
      'price': displaySalePrice,
      'original_price': displayPrice,
      'is_sale': hasSale,
      'image': proImage,
      'quantity': quantity,
    };
  }
}
