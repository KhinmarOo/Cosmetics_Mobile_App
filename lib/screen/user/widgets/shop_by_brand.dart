import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class ShopByBrandSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<CategoryModel> onCategorySelected;

  const ShopByBrandSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories.take(6).toList();

    if (visibleCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "SHOP BY BRAND",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1D15),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: visibleCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = visibleCategories[index];
              final isSelected = category.catId == selectedCategoryId;

              return _BrandItem(
                category: category,
                isSelected: isSelected,
                onTap: () => onCategorySelected(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _BrandItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    final brandImage = _brandImage(category.catName);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFFCF2),
                // gradient: const LinearGradient(
                //   colors: [
                //     Color(0xFFE6B31E),
                //     Color(0xFFF7F1E3),
                //     Color(0xFFE6B31E),
                //   ],
                // ),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2D1D15) : goldColor,
                  width: isSelected ? 2 : 0,
                ),
              ),
              child: Center(
                child: brandImage == null
                    ? const Icon(
                        Icons.spa_outlined,
                        color: Color(0xFF2D1D15),
                        size: 28,
                      )
                    : ClipOval(
                        child: Image.asset(
                          brandImage,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.spa_outlined,
                              color: Color(0xFF2D1D15),
                              size: 28,
                            );
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              category.catName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF2D1D15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _brandImage(String brandName) {
    final name = brandName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    const brandAssets = {
      'cutapro': 'assets/images/cutapro.png',
      'fraijour': 'assets/images/fraijour.png',
      'maybelline': 'assets/images/maybelline.png',
      'novo': 'assets/images/novo.png',
      'romand': 'assets/images/romand.png',
      'vaseline': 'assets/images/vaseline.png',
    };

    for (final entry in brandAssets.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }
}
