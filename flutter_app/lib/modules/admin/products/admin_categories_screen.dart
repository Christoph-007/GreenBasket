import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/products/create_category_screen.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  // Mock categories — replace with API call
  final List<Map<String, dynamic>> _categories = [
    {'id': 'C001', 'icon': '🥦', 'name': 'Vegetables', 'subcategories': 8, 'products': 124, 'active': true},
    {'id': 'C002', 'icon': '🍎', 'name': 'Fruits', 'subcategories': 6, 'products': 87, 'active': true},
    {'id': 'C003', 'icon': '🥛', 'name': 'Dairy & Eggs', 'subcategories': 4, 'products': 56, 'active': true},
    {'id': 'C004', 'icon': '🧺', 'name': 'Pantry Staples', 'subcategories': 10, 'products': 203, 'active': true},
    {'id': 'C005', 'icon': '🍵', 'name': 'Beverages', 'subcategories': 5, 'products': 78, 'active': false},
    {'id': 'C006', 'icon': '🌿', 'name': 'Herbs & Spices', 'subcategories': 3, 'products': 45, 'active': true},
  ];

  void _showOptionsMenu(BuildContext context, Map<String, dynamic> category) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(category['name'] as String, style: AppTextStyles.titleLarge),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.info),
              title: const Text('Edit Category'),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => const CreateCategoryScreen());
              },
            ),
            ListTile(
              leading: Icon(
                category['active'] as bool ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: AppColors.warning,
              ),
              title: Text(category['active'] as bool ? 'Deactivate' : 'Activate'),
              onTap: () {
                setState(() => category['active'] = !(category['active'] as bool));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Category', style: TextStyle(color: AppColors.error)),
              onTap: () {
                // TODO: Call API to delete category
                Navigator.pop(ctx);
                setState(() => _categories.remove(category));
                Get.snackbar('Deleted', '${category['name']} has been deleted.',
                    backgroundColor: AppColors.error, colorText: Colors.white);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateCategoryScreen()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Category', style: TextStyle(color: Colors.white)),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _categories.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _categories.removeAt(oldIndex);
            _categories.insert(newIndex, item);
          });
          // TODO: Call API to update category order
        },
        itemBuilder: (_, i) {
          final cat = _categories[i];
          return Card(
            key: ValueKey(cat['id']),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onLongPress: () => _showOptionsMenu(context, cat),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Icons.drag_handle, color: AppColors.textHint),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(cat['icon'] as String, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat['name'] as String, style: AppTextStyles.titleMedium),
                          Text(
                            '${cat['subcategories']} subcategories • ${cat['products']} products',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: cat['active'] as bool,
                      onChanged: (v) => setState(() => cat['active'] = v),
                      activeColor: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                      onPressed: () => _showOptionsMenu(context, cat),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
