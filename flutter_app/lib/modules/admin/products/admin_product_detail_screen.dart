import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import '../admin_controller.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AdminProductDetailScreen({super.key, this.product});

  @override
  State<AdminProductDetailScreen> createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  final controller = Get.find<AdminController>();
  late Map<String, dynamic> _product;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? Get.arguments?['product'] ?? {};
  }

  void _toggleStatus() async {
    final currentStatus = _product['status'] ?? 'Active';
    final newStatus = currentStatus == 'Active' ? 'Inactive' : 'Active';
    
    setState(() => _isLoading = true);
    try {
      // For now we use the existing update mechanism or snackbar placeholder
      // until toggleProductStatus is added to controller if needed
      setState(() {
        _product['status'] = newStatus;
      });
      Get.snackbar('Success', 'Product status updated to $newStatus',
          backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Product not found')));
    }

    final name = _product['name'] ?? 'Product Detail';
    final price = _product['price']?.toString() ?? '0';
    final stock = _product['stock']?.toString() ?? '0';
    final merchant = _product['merchant']?['businessName']?.toString() ?? _product['merchant']?['name']?.toString() ?? 'Unknown';
    final description = _product['description'] ?? 'No description available.';
    final category = _product['category']?['name']?.toString() ?? 'Uncategorized';
    final status = _product['status'] ?? 'Active';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryContainer,
                child: const Icon(Icons.eco_outlined, size: 80, color: AppColors.primary),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name, style: AppTextStyles.headlineLarge),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (status == 'Active' ? AppColors.success : AppColors.error).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: status == 'Active' ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('by $merchant', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                  const Divider(height: 32),
                  
                  _buildDetailRow('Price', '₹$price', Icons.payments_outlined),
                  _buildDetailRow('Stock', '$stock units', Icons.inventory_2_outlined),
                  _buildDetailRow('Category', category, Icons.category_outlined),
                  
                  const Divider(height: 32),
                  const Text('Description', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Text(description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  
                  const SizedBox(height: 40),
                  const Text('Admin Controls', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _toggleStatus,
                          icon: Icon(status == 'Active' ? Icons.pause_circle_outline : Icons.play_circle_outline),
                          label: Text(status == 'Active' ? 'Deactivate' : 'Activate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: status == 'Active' ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Edit product (reuse merchant edit screen logic?)
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Product'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Confirm delete
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Product'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
