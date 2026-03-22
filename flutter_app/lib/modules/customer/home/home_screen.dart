import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../widgets/cards/product_card.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../data/models/product_model.dart';
import 'home_controller.dart';
import '../cart/cart_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HomeController());
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.fetchData,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _Header()),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(Routes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.textHint, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Search for fresh produce...',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Banner carousel
              SliverToBoxAdapter(
                child: Obx(() => ctrl.isLoading.value
                    ? const SizedBox(height: 180, child: GBLoader())
                    : _BannerSection()),
              ),

              // Categories
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Shop by Category',
                  onSeeAll: () => Get.toNamed(Routes.categories),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() => ctrl.isLoading.value
                    ? _CategoryShimmer()
                    : _CategoriesRow(categories: ctrl.categories)),
              ),

              // Flash sales
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '⚡ Flash Sale',
                  subtitle: 'Limited time offers',
                  onSeeAll: () => Get.toNamed(Routes.categories),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() => ctrl.isLoading.value
                    ? _HorizontalProductsShimmer()
                    : _HorizontalProductsList(
                        products: ctrl.flashSaleProducts,
                        cartCtrl: cartCtrl,
                      )),
              ),

              // Featured products
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Featured Products',
                  onSeeAll: () => Get.toNamed(Routes.categories),
                ),
              ),
              Obx(() => ctrl.isLoading.value
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: GBLoader(),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = ctrl.featuredProducts[index];
                            return ProductCard(
                              product: product,
                              onAddToCart: () => cartCtrl.addItem(
                                  productId: product.id, quantity: 1),
                            );
                          },
                          childCount: ctrl.featuredProducts.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                      ),
                    )),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning! 👋',
                  style: AppTextStyles.bodySmall),
              SizedBox(height: 2),
              Text('What are you looking for?',
                  style: AppTextStyles.headlineMedium),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: () => Get.toNamed('/customer/notifications'),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerSection extends StatefulWidget {
  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  // Placeholder gradient banners until API banners are loaded
  final _bannerColors = [
    [AppColors.primary, AppColors.primaryDark],
    [AppColors.secondary, AppColors.secondaryDark],
    [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
  ];
  final _bannerTitles = [
    'Fresh Organic Produce\nDelivered Daily',
    'Flash Sale — Up to 40% Off\nSelected Items',
    'New Recipes Added\nCook Something Amazing',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _bannerColors.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _bannerColors[i],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _bannerTitles[i],
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Shop Now',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: _bannerColors[i][0]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerColors.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _currentPage
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headlineMedium),
              if (subtitle != null)
                Text(subtitle!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final List<CategoryModel> categories;
  const _CategoriesRow({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(height: 80);
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () =>
                Get.toNamed(Routes.categories, arguments: {'categoryId': cat.id}),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: cat.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: cat.image!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.eco_outlined,
                          color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: AppTextStyles.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalProductsList extends StatelessWidget {
  final List<ProductModel> products;
  final CartController cartCtrl;
  const _HorizontalProductsList({required this.products, required this.cartCtrl});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox(height: 220);
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: products.length,
        itemBuilder: (context, i) => SizedBox(
          width: 170,
          child: ProductCard(
            product: products[i],
            onAddToCart: () =>
                cartCtrl.addItem(productId: products[i].id, quantity: 1),
          ),
        ),
      ),
    );
  }
}

class _CategoryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 6,
        itemBuilder: (_, __) => const Column(
          children: [
            GBShimmerBox(width: 60, height: 60, borderRadius: 16),
            SizedBox(height: 6),
            GBShimmerBox(width: 50, height: 10),
          ],
        ),
      ),
    );
  }
}

class _HorizontalProductsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 4,
        itemBuilder: (_, __) => const SizedBox(
          width: 170,
          child: GBProductCardShimmer(),
        ),
      ),
    );
  }
}
