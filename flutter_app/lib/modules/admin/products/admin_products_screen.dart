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

  // Mock products — replace with API call
  final _products = [
    {'id': 'P001', 'name': 'Organic Spinach 500g', 'merchant': 'Fresh Farms', 'price': '₹60', 'stock': 45, 'status': 'Active', 'category': 'Vegetables'},
    {'id': 'P002', 'name': 'Fresh Tomatoes 1kg', 'merchant': 'Green Grocers', 'price': '₹60', 'stock': 120, 'status': 'Active', 'category': 'Vegetables'},
    {'id': 'P003', 'name': 'Baby Carrots 250g', 'merchant': 'Organic World', 'price': '₹45', 'stock': 0, 'status': 'Inactive', 'category': 'Vegetables'},
    {'id': 'P004', 'name': 'Alphonso Mangoes 1kg', 'merchant': 'Farm Fresh', 'price': '₹220', 'stock': 30, 'status': 'Active', 'category': 'Fruits'},
    {'id': 'P005', 'name': 'Wild Honey 500ml', 'merchant': 'Nature Basket', 'price': '₹350', 'stock': 15, 'status': 'Suspended', 'category': 'Pantry'},
    {'id': 'P006', 'name': 'Amul Full Cream Milk 1L', 'merchant': 'Dairy Direct', 'price': '₹68', 'stock': 200, 'status': 'Active', 'category': 'Dairy'},
  ];

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

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} Selected')
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
            child: products.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _buildProductCard(products[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final id = product['id'] as String;
    final isSelected = _selectedIds.contains(id);
    final status = product['status'] as String;
    final stock = product['stock'] as int;

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
                    Text(product['merchant'] as String, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(product['price'] as String, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
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
