class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final String merchantId;
  final String merchantName;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isOrganic;
  final bool isFeatured;
  final bool isAvailable;
  final String unit;
  final List<PreparationOption> preparationOptions;
  final String? nutritionalInfo;
  final bool isPreBookable;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.merchantId,
    required this.merchantName,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.stock,
    this.isOrganic = false,
    this.isFeatured = false,
    this.isAvailable = true,
    required this.unit,
    this.preparationOptions = const [],
    this.nutritionalInfo,
    this.isPreBookable = false,
  });

  double get effectivePrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  int get discountPercent =>
      hasDiscount ? ((1 - effectivePrice / price) * 100).round() : 0;

  String get primaryImage => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice']).toDouble()
          : null,
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['category']?['_id'] ?? json['categoryId'] ?? '',
      categoryName: json['category']?['name'] ?? json['categoryName'] ?? '',
      merchantId: json['merchant']?['_id'] ?? json['merchantId'] ?? '',
      merchantName: json['merchant']?['businessName'] ?? json['merchantName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      stock: json['stock'] ?? 0,
      isOrganic: json['isOrganic'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      unit: json['unit'] ?? 'kg',
      preparationOptions: (json['preparationOptions'] as List<dynamic>? ?? [])
          .map((e) => PreparationOption.fromJson(e))
          .toList(),
      nutritionalInfo: json['nutritionalInfo'],
      isPreBookable: json['isPreBookable'] ?? false,
    );
  }
}

class PreparationOption {
  final String id;
  final String name;
  final double additionalPrice;

  PreparationOption({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  factory PreparationOption.fromJson(Map<String, dynamic> json) {
    return PreparationOption(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      additionalPrice: (json['additionalPrice'] ?? 0).toDouble(),
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? image;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      productCount: json['productCount'] ?? 0,
    );
  }
}
