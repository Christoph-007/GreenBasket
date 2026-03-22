import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class _Ingredient {
  final String name;
  final String baseQty;
  final String unit;
  const _Ingredient(this.name, this.baseQty, this.unit);
}

class _RecipeDetailData {
  final String id;
  final String name;
  final int timeMinutes;
  final String difficulty;
  final int baseServings;
  final List<Color> gradientColors;
  final List<_Ingredient> ingredients;
  final List<String> instructions;

  const _RecipeDetailData({
    required this.id,
    required this.name,
    required this.timeMinutes,
    required this.difficulty,
    required this.baseServings,
    required this.gradientColors,
    required this.ingredients,
    required this.instructions,
  });
}

// Mock recipe detail — in production fetch by recipeId from Get.arguments
const _RecipeDetailData _mockRecipe = _RecipeDetailData(
  id: '3',
  name: 'Creamy Mushroom Pasta',
  timeMinutes: 25,
  difficulty: 'Easy',
  baseServings: 2,
  gradientColors: [Color(0xFF6D4C41), Color(0xFFBCAAA4)],
  ingredients: [
    _Ingredient('Penne Pasta', '200', 'g'),
    _Ingredient('Button Mushrooms', '250', 'g'),
    _Ingredient('Heavy Cream', '100', 'ml'),
    _Ingredient('Parmesan Cheese', '30', 'g'),
    _Ingredient('Garlic Cloves', '4', 'cloves'),
    _Ingredient('Olive Oil', '2', 'tbsp'),
    _Ingredient('Butter', '1', 'tbsp'),
    _Ingredient('Fresh Thyme', '1', 'sprig'),
    _Ingredient('Salt & Pepper', 'to', 'taste'),
  ],
  instructions: [
    'Bring a large pot of salted water to a boil. Cook pasta until al dente, reserve ½ cup pasta water before draining.',
    'Slice mushrooms and mince garlic cloves finely.',
    'Heat olive oil and butter in a large skillet over medium-high heat. Add mushrooms in a single layer and cook for 4–5 minutes until golden, without stirring.',
    'Add garlic and thyme, cook for 1 minute until fragrant.',
    'Reduce heat to medium. Pour in heavy cream and half of the reserved pasta water. Simmer for 2–3 minutes.',
    'Add cooked pasta to the skillet and toss to coat. Add remaining pasta water if sauce is too thick.',
    'Remove from heat, stir in parmesan cheese. Season with salt and pepper.',
    'Serve immediately, garnished with extra parmesan and fresh thyme leaves.',
  ],
);

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // In production: use Get.arguments['recipeId'] to fetch the recipe
  final _RecipeDetailData _recipe = _mockRecipe;
  int _servings = 2;

  double get _multiplier => _servings / _recipe.baseServings;

  String _scaleQty(String baseQty) {
    final num? value = num.tryParse(baseQty);
    if (value == null) return baseQty;
    final scaled = value * _multiplier;
    if (scaled == scaled.roundToDouble()) {
      return scaled.toInt().toString();
    }
    return scaled.toStringAsFixed(1);
  }

  Color get _difficultyColor {
    switch (_recipe.difficulty) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sliver app bar with gradient header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _recipe.gradientColors,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant_rounded,
                          color: Colors.white38, size: 80),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe name
                      Text(_recipe.name,
                          style: AppTextStyles.displayMedium),
                      const SizedBox(height: AppSpacing.sm),

                      // Meta row
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _MetaChip(
                            icon: Icons.access_time_rounded,
                            label: '${_recipe.timeMinutes} min',
                            color: AppColors.primary,
                          ),
                          _MetaChip(
                            icon: Icons.bar_chart_rounded,
                            label: _recipe.difficulty,
                            color: _difficultyColor,
                          ),
                          _MetaChip(
                            icon: Icons.people_outline_rounded,
                            label: '$_servings servings',
                            color: AppColors.secondary,
                          ),
                          _MetaChip(
                            icon: Icons.eco_outlined,
                            label:
                                '${_recipe.ingredients.length} ingredients',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Ingredients
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Ingredients',
                                style: AppTextStyles.titleLarge),
                          ),
                          // Serving stepper
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border:
                                  Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StepperButton(
                                  icon: Icons.remove_rounded,
                                  onTap: () {
                                    if (_servings > 1) {
                                      setState(() => _servings--);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm),
                                  child: Text('$_servings',
                                      style: AppTextStyles.titleMedium),
                                ),
                                _StepperButton(
                                  icon: Icons.add_rounded,
                                  onTap: () =>
                                      setState(() => _servings++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'For $_servings serving${_servings > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: List.generate(
                            _recipe.ingredients.length,
                            (i) {
                              final ing = _recipe.ingredients[i];
                              final isLast =
                                  i == _recipe.ingredients.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.sm),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(ing.name,
                                              style: AppTextStyles
                                                  .bodyMedium),
                                        ),
                                        Text(
                                          '${_scaleQty(ing.baseQty)} ${ing.unit}',
                                          style: AppTextStyles
                                              .titleMedium
                                              .copyWith(
                                                  color:
                                                      AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    const Divider(height: 1),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Instructions
                      const Text('Instructions',
                          style: AppTextStyles.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ...List.generate(
                          _recipe.instructions.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 3),
                                  child: Text(
                                    _recipe.instructions[i],
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(height: 1.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Bottom space for FAB
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, -2)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add all ingredients to cart
                    Get.snackbar(
                      'Added to Cart',
                      'All ${_recipe.ingredients.length} ingredients added for $_servings serving${_servings > 1 ? 's' : ''}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_rounded,
                      size: 20),
                  label: const Text('Add All Ingredients to Cart'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
