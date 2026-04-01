import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.icon,
    this.subCategories = const [],
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;
  final List<String> subCategories;
  final bool isActive;

  @override
  List<Object?> get props => [id];
}
