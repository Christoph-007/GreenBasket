import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/config/routes.dart';

// Mock product data model for this screen
// In production, use the real ProductModel from product_model.dart
class _MockProduct {
  final String id;
  final String name;
  final String merchantName;
  final double price;
  final double? discountPrice;
  final bool isOrganic;
  final double rating;
  final int reviewCount;
  final String unit;

  const _MockProduct({
    required this.id,
    required this.name,
    required this.merchantName,
    required this.price,
    this.discountPrice,
    this.isOrganic = false,
    this.rating = 0,
    this.reviewCount = 0,
    required this.unit,
  });

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null;
  int get discountPercent => hasDiscount
      ? ((price - discountPrice!) / price * 100).round()
      : 0;
}

const List<_MockProduct> _allProducts = [
  _MockProduct(
    id: '1',
    name: 'Organic Baby Spinach',
    merchantName: 'Green Farms',
    price: 85,
    discountPrice: 65,
    isOrganic: true,
    rating: 4.7,
    reviewCount: 128,
    unit: '250g',
  ),
  _MockProduct(
    id: '2',
    name: 'Fresh Cherry Tomatoes',
    merchantName: 'Sun Harvest',
    price: 60,
    rating: 4.3,
    reviewCount: 74,
    unit: '500g',
  ),
  _MockProduct(
    id: '3',
    name: 'Broccoli Florets',
    merchantName: 'Green Farms',
    price: 75,
    discountPrice: 60,
    isOrganic: true,
    rating: 4.5,
    reviewCount: 52,
    unit: '400g',
  ),
  _MockProduct(
    id: '4',
    name: 'Sweet Corn (4 pcs)',
    merchantName: 'Sun Harvest',
    price: 40,
    rating: 4.1,
    reviewCount: 89,
    unit: '4 pcs',
  ),
  _MockProduct(
    id: '5',
    name: 'Purple Cabbage',
    merchantName: 'Veggie World',
    price: 55,
    isOrganic: true,
    rating: 4.4,
    reviewCount: 34,
    unit: '500g',
  ),
  _MockProduct(
    id: '6',
    name: 'Mixed Bell Peppers',
    merchantName: 'Veggie World',
    price: 120,
    discountPrice: 99,
    rating: 4.6,
    reviewCount: 113,
    unit: '3 pcs',
  ),
];

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key});

  @override
  State<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // Read from arguments in production
  String get _categoryName {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['categoryName'] as String? ?? 'Vegetables';
  }

  String _sortBy = 'relevance';
  bool _organicOnly = false;
  // _inStockOnly filter reserved for future use
  // bool _inStockOnly = false;
  String _priceRange = 'all';

  List<_MockProduct> get _filteredProducts {
    var list = List<_MockProduct>.from(_allProducts);
    if (_organicOnly) list = list.where((p) => p.isOrganic).toList();
    switch (_priceRange) {
      case 'under_50':
        list = list.where((p) => p.effectivePrice < 50).toList();
        break;
      case '50_100':
        list = list
            .where(
                (p) => p.effectivePrice >= 50 && p.effectivePrice <= 100)
            .toList();
        break;
      case 'above_100':
        list =
            list.where((p) => p.effectivePrice > 100).toList();
        break;
    }
    switch (_sortBy) {
      case 'price_low':
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  void _showSortSheet() {
    final options = [
      ('relevance', 'Relevance'),
      ('price_low', 'Price: Low to High'),
      ('price_high', 'Price: High to Low'),
      ('rating', 'Rating'),
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Sort By', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...options.map((opt) => ListTile(
                title: Text(opt.$2, style: AppTextStyles.bodyMedium),
                trailing: _sortBy == opt.$1
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _sortBy = opt.$1);
                  Get.back();
                },
              )),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(_categoryName, style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: AppColors.textPrimary),
            onPressed: () => Get.toNamed(Routes.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: AppColors.surface,
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              children: [
                // Sort chip
                _FilterChip(
                  label: 'Sort',
                  icon: Icons.sort_rounded,
                  isActive: _sortBy != 'relevance',
                  onTap: _showSortSheet,
                ),
                const SizedBox(width: AppSpacing.sm),
                // Organic chip
                _FilterChip(
                  label: 'Organic',
                  icon: Icons.eco_rounded,
                  isActive: _organicOnly,
                  onTap: () =>
                      setState(() => _organicOnly = !_organicOnly),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Price range chips
                _FilterChip(
                  label: 'Under ₹50',
                  isActive: _priceRange == 'under_50',
                  onTap: () => setState(() => _priceRange =
                      _priceRange == 'under_50' ? 'all' : 'under_50'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: '₹50 - ₹100',
                  isActive: _priceRange == '50_100',
                  onTap: () => setState(() => _priceRange =
                      _priceRange == '50_100' ? 'all' : '50_100'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Above ₹100',
                  isActive: _priceRange == 'above_100',
                  onTap: () => setState(() => _priceRange =
                      _priceRange == 'above_100' ? 'all' : 'above_100'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  '${products.length} products',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (_sortBy != 'relevance' ||
                    _organicOnly ||
                    _priceRange != 'all')
                  GestureDetector(
                    onTap: () => setState(() {
                      _sortBy = 'relevance';
                      _organicOnly = false;
                      _priceRange = 'all';
                    }),
                    child: Text(
                      'Clear Filters',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),

          // Product grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            color: AppColors.textHint, size: 64),
                        const SizedBox(height: AppSpacing.md),
                        const Text('No products found',
                            style: AppTextStyles.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => setState(() {
                            _sortBy = 'relevance';
                            _organicOnly = false;
                            _priceRange = 'all';
                          }),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) =>
                        _ProductGridCard(product: products[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: isActive ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatefulWidget {
  final _MockProduct product;
  const _ProductGridCard({required this.product});

  @override
  State<_ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<_ProductGridCard> {
  bool _inWishlist = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.productDetail,
        arguments: {'productId': product.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                  ),
                  child: const Icon(Icons.eco_outlined,
                      size: 48, color: AppColors.primary),
                ),
                if (product.isOrganic)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Organic',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _inWishlist = !_inWishlist),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _inWishlist
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: _inWishlist
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.titleMedium
                          .copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(product.merchantName,
                        style: AppTextStyles.bodySmall),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.effectivePrice.toInt()}/${product.unit}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            if (product.hasDiscount)
                              Text(
                                '₹${product.price.toInt()}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  decoration:
                                      TextDecoration.lineThrough,
                                  color: AppColors.textHint,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: Add to cart
                            Get.snackbar(
                              'Added',
                              '${product.name} added to cart',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 1),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    if (product.reviewCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.secondary, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
