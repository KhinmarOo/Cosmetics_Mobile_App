class ProductModel {
  final String proId;
  final String proName;
  final String proImage;
  final double proPrice;
  final int proQty;
  final String proDescription;
  final String catId;

  ProductModel({
    required this.proId,
    required this.proName,
    required this.proImage,
    required this.proPrice,
    required this.proQty,
    required this.proDescription,
    required this.catId,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      proId: map['pro_id'].toString(),
      proName: map['pro_name'] ?? '',
      proImage: map['pro_image'] ?? '',
      proPrice: (map['pro_price'] ?? 0).toDouble(),
      proQty: map['pro_qty'] ?? 0,
      proDescription: map['pro_description'] ?? '',
      catId: map['cat_id'].toString(),
    );
  }
}