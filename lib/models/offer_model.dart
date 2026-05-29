class OfferModel {
  final String offerId;
  final String proId;
  final String productName;
  final String productImage;
  final double productPrice;
  final double offerPrice;
  final String offerDescription;
  final DateTime? createdAt;

  const OfferModel({
    required this.offerId,
    required this.proId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.offerPrice,
    required this.offerDescription,
    this.createdAt,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    final product = map['products'] as Map<String, dynamic>?;

    return OfferModel(
      offerId: map['offer_id'].toString(),
      proId: map['pro_id'].toString(),
      productName: product?['pro_name']?.toString() ?? '',
      productImage: product?['pro_image']?.toString() ?? '',
      productPrice: (product?['pro_price'] as num?)?.toDouble() ?? 0,
      offerPrice: (map['offer_price'] as num?)?.toDouble() ?? 0,
      offerDescription: map['offer_description']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }
}
