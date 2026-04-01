import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.comparePrice,
    required this.unit,
    required this.stock,
    required this.primaryImage,
    this.images = const [],
    this.tags = const [],
    this.averageRating = 0,
    this.totalReviews = 0,
    this.categoryId = '',
    this.categoryName = '',
    this.merchantName = '',
    this.nutritionalInfo,
    this.preparationOptions = const [],
    this.isPremiumExclusive = false,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double? comparePrice;
  final String unit;
  final int stock;
  final String primaryImage;
  final List<String> images;
  final List<String> tags;
  final double averageRating;
  final int totalReviews;
  final String categoryId;
  final String categoryName;
  final String merchantName;
  final NutritionalInfo? nutritionalInfo;
  final List<PreparationOption> preparationOptions;
  final bool isPremiumExclusive;

  bool get hasDiscount => comparePrice != null && comparePrice! > price;
  int get discountPercent => hasDiscount
      ? ((comparePrice! - price) / comparePrice! * 100).round()
      : 0;
  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [id];
}

class NutritionalInfo extends Equatable {
  const NutritionalInfo({
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
    this.vitamins = const [],
  });

  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fat;
  final double? fiber;
  final List<String> vitamins;

  @override
  List<Object?> get props => [calories, protein, carbohydrates, fat];
}

class PreparationOption extends Equatable {
  const PreparationOption({required this.type, this.additionalPrice = 0});

  final String type;
  final double additionalPrice;

  @override
  List<Object?> get props => [type, additionalPrice];
}
