class CategoryModel {
  final String catId; // UUID ဖြစ်ရင် String သုံးပါ
  final String catName;

  CategoryModel({required this.catId, required this.catName});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      catId: map['cat_id']?.toString() ?? '',
      catName: map['cat_name']?.toString() ?? '', // DB column နာမည်အတိုင်း
    );
  }
}