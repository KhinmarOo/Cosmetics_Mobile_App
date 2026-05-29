import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/offer_model.dart';
import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/offer_service.dart';
import '../../services/product_service.dart';
import 'widgets/product_section.dart';
import 'widgets/shop_by_brand.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeMore;
  final List<ProductModel> favoritedProducts;
  final ValueChanged<ProductModel> onFavoriteToggle;
  final void Function(ProductModel product, int quantity) onAddToCart;
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onCartPressed;

  const HomeScreen({
    super.key,
    this.onSeeMore,
    required this.favoritedProducts,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.cartItems,
    required this.onCartPressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  final OfferService _offerService = OfferService();
  final ProductService _productService = ProductService();
  final PageController _bannerController = PageController(initialPage: 0);
  final TextEditingController _searchController = TextEditingController();
  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<OfferModel>> _offersFuture;
  late Future<_HomeProductData> _productsFuture;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _searchQuery = '';
  int _currentBannerPage = 0;
  int _offerCount = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
    _offersFuture = _offerService.getOffers();
    _productsFuture = _loadHomeProducts();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_offerCount <= 1) return;
      _currentBannerPage = (_currentBannerPage + 1) % _offerCount;

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = widget.cartItems.fold<int>(
      0,
      (total, item) => total + (item["quantity"] as int? ?? 0),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _HomeStickyHeader(
              cartCount: cartCount,
              onCartPressed: widget.onCartPressed,
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFD4AF37),
                onRefresh: _refreshHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _OfferCarousel(
                        offersFuture: _offersFuture,
                        controller: _bannerController,
                        currentPage: _currentBannerPage,
                        onOfferCountChanged: (count) => _offerCount = count,
                        onPageChanged: (index) {
                          setState(() => _currentBannerPage = index);
                        },
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<CategoryModel>>(
                        future: _categoriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 88,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                "Failed to load brands: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          return ShopByBrandSection(
                            categories: snapshot.data ?? [],
                            selectedCategoryId: _selectedCategoryId,
                            onCategorySelected: (category) {
                              setState(() {
                                if (_selectedCategoryId == category.catId) {
                                  _selectedCategoryId = null;
                                  _selectedCategoryName = null;
                                } else {
                                  _selectedCategoryId = category.catId;
                                  _selectedCategoryName = category.catName;
                                }
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<_HomeProductData>(
                        future: _productsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Text(
                                "Failed to load products: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final productData = snapshot.data;
                          final allProducts = productData?.allProducts ?? [];
                          final categoryProducts = _selectedCategoryId == null
                              ? allProducts
                              : allProducts
                                    .where(
                                      (product) =>
                                          product.catId == _selectedCategoryId,
                                    )
                                    .toList();
                          final products = categoryProducts
                              .where(
                                (product) => _matchesProductSearch(
                                  product,
                                  _searchQuery,
                                ),
                              )
                              .toList();
                          final newProducts = products.take(4).toList();
                          final popularProducts = productData?.popularProducts
                              .where(
                                (product) =>
                                    _selectedCategoryId == null ||
                                    product.catId == _selectedCategoryId,
                              )
                              .where(
                                (product) => _matchesProductSearch(
                                  product,
                                  _searchQuery,
                                ),
                              )
                              .take(4)
                              .toList();
                          final isSearching = _normalizeSearchText(
                            _searchQuery,
                          ).isNotEmpty;

                          if (isSearching) {
                            return ProductSection(
                              title: "Search Results",
                              products: products,
                              favoritedProducts: widget.favoritedProducts,
                              onFavoriteToggle: widget.onFavoriteToggle,
                              onAddToCart: widget.onAddToCart,
                            );
                          }

                          if (_selectedCategoryId != null) {
                            return ProductSection(
                              title:
                                  "${_selectedCategoryName ?? "Brand"} Products",
                              products: products,
                              favoritedProducts: widget.favoritedProducts,
                              onFavoriteToggle: widget.onFavoriteToggle,
                              onAddToCart: widget.onAddToCart,
                            );
                          }

                          return Column(
                            children: [
                              ProductSection(
                                title: "New Products",
                                products: newProducts,
                                favoritedProducts: widget.favoritedProducts,
                                onFavoriteToggle: widget.onFavoriteToggle,
                                onAddToCart: widget.onAddToCart,
                              ),
                              const SizedBox(height: 10),
                              ProductSection(
                                title: "Popular Products",
                                products: popularProducts ?? [],
                                onSeeMore: widget.onSeeMore,
                                favoritedProducts: widget.favoritedProducts,
                                onFavoriteToggle: widget.onFavoriteToggle,
                                onAddToCart: widget.onAddToCart,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<_HomeProductData> _loadHomeProducts() async {
    final results = await Future.wait([
      _productService.getProductsWithOffers(),
      _productService.getPopularProductsWithOffers(limit: 4),
    ]);

    return _HomeProductData(
      allProducts: results[0],
      popularProducts: results[1],
    );
  }

  Future<void> _refreshHomeData() async {
    final categoriesFuture = _categoryService.getCategories();
    final offersFuture = _offerService.getOffers();
    final productsFuture = _loadHomeProducts();

    setState(() {
      _currentBannerPage = 0;
      _offerCount = 0;
      _categoriesFuture = categoriesFuture;
      _offersFuture = offersFuture;
      _productsFuture = productsFuture;
    });

    await Future.wait([categoriesFuture, offersFuture, productsFuture]);
  }

  bool _matchesProductSearch(ProductModel product, String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return true;

    final searchableText = _normalizeSearchText(
      "${product.proName} ${product.proDescription} ${product.displayPrice}",
    );
    final compactQuery = normalizedQuery.replaceAll(' ', '');
    final compactText = searchableText.replaceAll(' ', '');

    if (searchableText.contains(normalizedQuery) ||
        compactText.contains(compactQuery)) {
      return true;
    }

    final queryWords = normalizedQuery
        .split(' ')
        .where((word) => word.isNotEmpty);
    return queryWords.every(searchableText.contains);
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'[.,/#!$%^&*;:{}=+`~()\[\]<>?|"\\]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _HomeProductData {
  final List<ProductModel> allProducts;
  final List<ProductModel> popularProducts;

  const _HomeProductData({
    required this.allProducts,
    required this.popularProducts,
  });
}

class _OfferCarousel extends StatelessWidget {
  final Future<List<OfferModel>> offersFuture;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onOfferCountChanged;
  final ValueChanged<int> onPageChanged;

  const _OfferCarousel({
    required this.offersFuture,
    required this.controller,
    required this.currentPage,
    required this.onOfferCountChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OfferModel>>(
      future: offersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          onOfferCountChanged(0);
          return const SizedBox(
            height: 145,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          onOfferCountChanged(0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Failed to load offers: ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        }

        final offers = snapshot.data ?? [];
        onOfferCountChanged(offers.length);

        if (offers.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 145,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: offers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OfferBannerCard(
                  offer: offers[index],
                  activePage: currentPage,
                  pageCount: offers.length,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OfferBannerCard extends StatelessWidget {
  final OfferModel offer;
  final int activePage;
  final int pageCount;

  const _OfferBannerCard({
    required this.offer,
    required this.activePage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const lightGoldColor = Color(0xFFF5EDD8);
    const darkBrown = Color(0xFF2D1D15);
    final originalPrice = _formatPrice(offer.productPrice);
    final offerPrice = _formatPrice(offer.offerPrice);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 335;
        final imageSize = compact ? 70.0 : 74.0;
        final offerPriceWidth = compact ? 100.0 : 112.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: goldColor),
            gradient: const SweepGradient(
              center: Alignment(0.08, 0.05),
              startAngle: 0.45,
              endAngle: 6.73,
              colors: [
                lightGoldColor,
                lightGoldColor,
                goldColor,
                goldColor,
                lightGoldColor,
                lightGoldColor,
              ],
              stops: [0.0, 0.18, 0.38, 0.63, 0.82, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: RadialGradient(
                      center: const Alignment(0.28, 0.02),
                      radius: 0.72,
                      colors: [
                        Colors.white.withValues(alpha: 0.62),
                        lightGoldColor.withValues(alpha: 0.34),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 22,
                child: _OfferProductImage(
                  imageUrl: offer.productImage,
                  size: imageSize,
                ),
              ),
              Positioned(
                left: compact ? 104 : 122,
                right: 14,
                top: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      offer.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: compact ? 12.5 : 13.5,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "$originalPrice MMK",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: compact ? 10 : 11,
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: offerPriceWidth,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD4AF37),
                                Color(0xFFF7F1E3),
                                Color(0xFFD4AF37),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "$offerPrice MMK",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFFFF3345),
                              fontSize: compact ? 12.5 : 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: compact ? 34 : 48,
                right: compact ? 12 : 18,
                bottom: 21,
                child: Container(
                  height: 27,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        const Color(0xFFD4AF37).withValues(alpha: 0.52),
                        const Color(0xFFF7F1E3).withValues(alpha: 0.74),
                        const Color(0xFFD4AF37).withValues(alpha: 0.52),
                      ],
                    ),
                  ),
                  child: Text(
                    offer.offerDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pageCount,
                    (index) => Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == activePage
                            ? goldColor
                            : Colors.white.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(2);
  }
}

class _OfferProductImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _OfferProductImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.spa_outlined, size: 42, color: goldColor),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.white.withValues(alpha: 0.52),
            child: const Icon(
              Icons.broken_image_outlined,
              size: 38,
              color: goldColor,
            ),
          );
        },
      ),
    );
  }
}

class _HomeStickyHeader extends StatelessWidget {
  final int cartCount;
  final VoidCallback onCartPressed;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _HomeStickyHeader({
    required this.cartCount,
    required this.onCartPressed,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkBrown = Color(0xFF2D1D15);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 10,
                          top: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/cosmetic_logo.png',
                              width: 26,
                              height: 26,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: goldColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.spa_outlined,
                                    color: goldColor,
                                    size: 17,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          bottom: 0,
                          child: Text(
                            "Beauty with me.",
                            style: TextStyle(
                              color: goldColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _HomeCartButton(count: cartCount, onPressed: onCartPressed),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFFFFFCF2),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.5),
                width: 1,
              ),
              // gradient: const LinearGradient(
              //   colors: [
              //     Color(0xFFD4AF37),
              //     Color(0xFFF7F1E3),
              //     Color(0xFFD4AF37),
              //   ],
              // ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: darkBrown, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: darkBrown),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCartButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _HomeCartButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: goldColor),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? "99+" : "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
