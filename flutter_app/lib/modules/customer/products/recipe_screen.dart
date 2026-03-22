import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/config/routes.dart';

class _Recipe {
  final String id;
  final String name;
  final String category;
  final int timeMinutes;
  final String difficulty;
  final int ingredientCount;
  final List<Color> gradientColors;

  const _Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.timeMinutes,
    required this.difficulty,
    required this.ingredientCount,
    required this.gradientColors,
  });
}

// Mock recipe data
const List<_Recipe> _mockRecipes = [
  _Recipe(
    id: '1',
    name: 'Avocado & Spinach Smoothie Bowl',
    category: 'Breakfast',
    timeMinutes: 10,
    difficulty: 'Easy',
    ingredientCount: 7,
    gradientColors: [Color(0xFF2E7D32), Color(0xFF81C784)],
  ),
  _Recipe(
    id: '2',
    name: 'Lemon Herb Grilled Chicken',
    category: 'Lunch',
    timeMinutes: 35,
    difficulty: 'Medium',
    ingredientCount: 11,
    gradientColors: [Color(0xFFF57F17), Color(0xFFFFCC02)],
  ),
  _Recipe(
    id: '3',
    name: 'Creamy Mushroom Pasta',
    category: 'Dinner',
    timeMinutes: 25,
    difficulty: 'Easy',
    ingredientCount: 9,
    gradientColors: [Color(0xFF6D4C41), Color(0xFFBCAAA4)],
  ),
  _Recipe(
    id: '4',
    name: 'Mango Chia Pudding',
    category: 'Desserts',
    timeMinutes: 15,
    difficulty: 'Easy',
    ingredientCount: 5,
    gradientColors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
  ),
  _Recipe(
    id: '5',
    name: 'Baked Veggie Spring Rolls',
    category: 'Snacks',
    timeMinutes: 40,
    difficulty: 'Hard',
    ingredientCount: 14,
    gradientColors: [Color(0xFF1565C0), Color(0xFF90CAF9)],
  ),
  _Recipe(
    id: '6',
    name: 'Dal Tadka with Jeera Rice',
    category: 'Dinner',
    timeMinutes: 45,
    difficulty: 'Medium',
    ingredientCount: 16,
    gradientColors: [Color(0xFF880E4F), Color(0xFFF48FB1)],
  ),
];

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Desserts',
  ];

  List<_Recipe> get _filtered {
    return _mockRecipes.where((r) {
      final matchCat =
          _selectedCategory == 'All' || r.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filtered;
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
        title: const Text('Recipes & Meal Ideas',
            style: AppTextStyles.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textHint, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Category filter
          Container(
            color: AppColors.surface,
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              itemCount: _categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Recipe grid
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu_rounded,
                            color: AppColors.textHint, size: 64),
                        const SizedBox(height: AppSpacing.md),
                        Text('No recipes found',
                            style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding:
                        const EdgeInsets.all(AppSpacing.screenPadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (_, i) =>
                        _RecipeCard(recipe: recipes[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final _Recipe recipe;
  const _RecipeCard({required this.recipe});

  Color get _difficultyColor {
    switch (recipe.difficulty) {
      case 'Easy':
        return AppColors.success;
      case 'Hard':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.recipeDetail,
        arguments: {'recipeId': recipe.id},
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
            // Gradient image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: recipe.gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.restaurant_rounded,
                        color: Colors.white54, size: 40),
                  ),
                  // Time badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: Colors.white, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            '${recipe.timeMinutes}m',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTextStyles.titleMedium
                          .copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppRadius.full),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _difficultyColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Ingredient count
                        const Icon(Icons.eco_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.ingredientCount}',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
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
