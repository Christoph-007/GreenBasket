import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/modules/admin/products/create_recipe_screen.dart';

class AdminRecipesScreen extends StatefulWidget {
  const AdminRecipesScreen({super.key});

  @override
  State<AdminRecipesScreen> createState() => _AdminRecipesScreenState();
}

class _AdminRecipesScreenState extends State<AdminRecipesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock recipes — replace with API call
  final List<Map<String, dynamic>> _recipes = [
    {'id': 'R001', 'name': 'Palak Paneer', 'author': 'Chef Anita', 'ingredients': 12, 'status': 'Published', 'category': 'Lunch'},
    {'id': 'R002', 'name': 'Mango Smoothie Bowl', 'author': 'Admin', 'ingredients': 8, 'status': 'Published', 'category': 'Breakfast'},
    {'id': 'R003', 'name': 'Veggie Stir-fry', 'author': 'Chef Raj', 'ingredients': 10, 'status': 'Draft', 'category': 'Dinner'},
    {'id': 'R004', 'name': 'Carrot Halwa', 'author': 'Admin', 'ingredients': 6, 'status': 'Published', 'category': 'Snacks'},
    {'id': 'R005', 'name': 'Dal Tadka', 'author': 'Chef Anita', 'ingredients': 9, 'status': 'Draft', 'category': 'Lunch'},
  ];

  Color _statusColor(String status) {
    return status == 'Published' ? AppColors.success : AppColors.textSecondary;
  }

  List<Map<String, dynamic>> get _filtered {
    return _recipes.where((r) =>
        (r['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (r['author'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showRecipeOptions(Map<String, dynamic> recipe) {
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.full)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(recipe['name'] as String, style: AppTextStyles.titleLarge),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.info),
              title: const Text('Edit Recipe'),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => const CreateRecipeScreen());
              },
            ),
            ListTile(
              leading: Icon(
                recipe['status'] == 'Published' ? Icons.unpublished_outlined : Icons.publish,
                color: AppColors.warning,
              ),
              title: Text(recipe['status'] == 'Published' ? 'Unpublish' : 'Publish'),
              onTap: () {
                setState(() => recipe['status'] = recipe['status'] == 'Published' ? 'Draft' : 'Published');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Recipe', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _recipes.remove(recipe));
                Get.snackbar('Deleted', '${recipe['name']} deleted.',
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recipes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateRecipeScreen()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Recipe', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search recipes or authors...',
                prefixIcon: Icon(Icons.search, color: AppColors.textHint),
              ),
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? const Center(child: Text('No recipes found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: recipes.length,
                    itemBuilder: (_, i) => _buildRecipeCard(recipes[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final status = recipe['status'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to recipe detail
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.primaryLight.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.restaurant_menu, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(recipe['name'] as String, style: AppTextStyles.titleMedium)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    const SizedBox(height: 4),
                    Text('By ${recipe['author']}', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            recipe['category'] as String,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.local_grocery_store_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text('${recipe['ingredients']} ingredients', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onPressed: () => _showRecipeOptions(recipe),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
