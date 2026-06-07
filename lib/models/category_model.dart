class CategoryModel {
  final String catId;
  final String catName;
  final String catImage;

  const CategoryModel({
    required this.catId,
    required this.catName,
    required this.catImage,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      catId: map['cat_id']?.toString() ?? '',
      catName: map['cat_name']?.toString() ?? '',
      catImage: map['cat_image']?.toString() ?? '',
    );
  }
}
