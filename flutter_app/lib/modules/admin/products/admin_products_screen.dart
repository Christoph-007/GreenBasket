import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchController = TextEditingController();
  final _selectedIds = <String>{};
  bool _selectionMode = false;
  String _searchQuery = '';


  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.success;
      case 'Inactive':
        return AppColors.textSecondary;
      default:
        return AppColors.error;
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products
        .where((p) =>
            (p['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p['merchant'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
        .cast<Map<String, dynamic>>();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Sort & Filter', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Text('Category', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['All', 'Vegetables', 'Fruits', 'Dairy', 'Pantry']
                  .map((c) => FilterChip(label: Text(c), selected: false, onSelected: (_) {}))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Status', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['All', 'Active', 'Inactive', 'Suspended']
                  .map((s) => FilterChip(label: Text(s), selected: false, onSelected: (_) {}))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Sort By', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['Name', 'Price: Low-High', 'Price: High-Low', 'Stock']
                  .map((s) => FilterChip(label: Text(s), selected: false, onSelected: (_) {}))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showBulkActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_selectedIds.length} product(s) selected', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _bulkAction(Icons.check_circle_outline, 'Activate Selected', AppColors.success),
            _bulkAction(Icons.pause_circle_outline, 'Suspend Selected', AppColors.warning),
            _bulkAction(Icons.delete_outline, 'Delete Selected', AppColors.error),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _bulkAction(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
      onTap: () {
        // TODO: Call API to bulk update status
        Navigator.pop(context);
        setState(() {
          _selectedIds.clear();
          _selectionMode = false;
        });
        Get.snackbar('Done', '$label applied.', backgroundColor: color, colorText: Colors.white);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _selectionMode
            ? Obx(() => Text('${_selectedIds.length} Selected'))
            : const Text('Products Management'),
        leading: IconButton(
          icon: Icon(_selectionMode ? Icons.close : Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (_selectionMode) {
              setState(() {
                _selectionMode = false;
                _selectedIds.clear();
              });
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          if (_selectionMode)
            TextButton(
              onPressed: _selectedIds.isNotEmpty ? _showBulkActionsSheet : null,
              child: const Text('Actions'),
            )
          else
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search products or merchants...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: Icon(
                    _selectionMode ? Icons.check_box : Icons.check_box_outline_blank,
                    color: AppColors.primary,
                  ),
                  onPressed: () => setState(() {
                    _selectionMode = !_selectionMode;
                    _selectedIds.clear();
                  }),
                  tooltip: 'Select multiple',
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredProducts = controller.products.where((p) {
                final product = p as Map<String, dynamic>;
                final searchMatch = (product['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                    (product['merchant']?['name']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                // TODO: Add category and status filters from _showFilterSheet state
                return searchMatch;
              }).toList();

              if (filteredProducts.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: filteredProducts.length,
                itemBuilder: (_, i) => _buildProductCard(filteredProducts[i] as Map<String, dynamic>),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final id = product['_id'] ?? product['id'];
    final isSelected = _selectedIds.contains(id);
    final status = product['status'] ?? 'Active';
    final stock = product['stock'] ?? 0;
    final merchantName = product['merchant']?['name']?.toString() ?? 'Unknown Merchant';
    final price = product['price']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          if (_selectionMode) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(id);
              } else {
                _selectedIds.add(id);
              }
            });
          } else {
            // TODO: Navigate to product detail screen
          }
        },
        onLongPress: () {
          setState(() {
            _selectionMode = true;
            _selectedIds.add(id);
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              if (_selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(id);
                        } else {
                          _selectedIds.add(id);
                        }
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.eco_outlined, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'] as String, style: AppTextStyles.labelLarge),
                    Text(merchantName, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('₹$price', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          stock == 0 ? 'Out of stock' : 'Stock: $stock',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: stock == 0 ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(color: _statusColor(status)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
