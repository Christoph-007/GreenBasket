import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../widgets/cards/product_card.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../widgets/common/empty_state.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _repo = ProductRepository();
  List<ProductModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      _items = await _repo.getWishlist();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _remove(String productId) async {
    await _repo.removeFromWishlist(productId);
    setState(() => _items.removeWhere((p) => p.id == productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GBAppBar(title: 'Wishlist'),
      body: _isLoading
          ? const GBLoader()
          : _items.isEmpty
              ? EmptyState(
                  icon: Icons.favorite_border,
                  title: 'Your wishlist is empty',
                  message: 'Save items you love to your wishlist',
                  actionLabel: 'Browse Products',
                  onAction: () => Get.toNamed(Routes.categories),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) => ProductCard(
                    product: _items[i],
                    isInWishlist: true,
                    onWishlistToggle: () => _remove(_items[i].id),
                  ),
                ),
    );
  }
}
