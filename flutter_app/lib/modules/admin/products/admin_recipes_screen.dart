import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import '../admin_controller.dart';
import 'create_recipe_screen.dart';

class AdminRecipesScreen extends StatefulWidget {
  const AdminRecipesScreen({super.key});

  @override
  State<AdminRecipesScreen> createState() => _AdminRecipesScreenState();
}

class _AdminRecipesScreenState extends State<AdminRecipesScreen> {
  final controller = Get.find<AdminController>();
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    return status.toLowerCase() == 'published' ? AppColors.success : AppColors.textSecondary;
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
            Text(recipe['name']?.toString() ?? 'Recipe', style: AppTextStyles.titleLarge),
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
                recipe['status']?.toString().toLowerCase() == 'published' ? Icons.unpublished_outlined : Icons.publish,
                color: AppColors.warning,
              ),
              title: Text(recipe['status']?.toString().toLowerCase() == 'published' ? 'Unpublish' : 'Publish'),
              onTap: () {
                // TODO: Call API to toggle status
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Recipe', style: TextStyle(color: AppColors.error)),
              onTap: () {
                // TODO: Call API to delete recipe
                Navigator.pop(ctx);
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
  Widget build(BuildContext context) {
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
              onChanged: (v) => _searchQuery.value = v,
              decoration: const InputDecoration(
                hintText: 'Search recipes or authors...',
                prefixIcon: Icon(Icons.search, color: AppColors.textHint),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final recipeList = controller.recipes.where((r) {
                final recipe = r as Map<String, dynamic>;
                final name = recipe['name']?.toString().toLowerCase() ?? '';
                final author = recipe['author']?['name']?.toString().toLowerCase() ?? '';
                final query = _searchQuery.value.toLowerCase();
                return name.contains(query) || author.contains(query);
              }).toList();

              if (recipeList.isEmpty) {
                return const Center(child: Text('No recipes found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: recipeList.length,
                itemBuilder: (_, i) => _buildRecipeCard(recipeList[i] as Map<String, dynamic>),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final status = recipe['status']?.toString() ?? 'Draft';
    final name = recipe['name']?.toString() ?? 'N/A';
    final authorName = recipe['author']?['name']?.toString() ?? 'Admin';
    final category = recipe['category']?['name'] ?? recipe['category']?.toString() ?? 'General';
    final ingredientsCount = (recipe['ingredients'] as List?)?.length ?? 0;

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
                        Expanded(child: Text(name, style: AppTextStyles.titleMedium)),
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
                    Text('By $authorName', style: AppTextStyles.bodySmall),
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
                            category,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.local_grocery_store_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text('$ingredientsCount ingredients', style: AppTextStyles.bodySmall),
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
