import 'package:equatable/equatable.dart';

class Cart extends Equatable {
  const Cart({
    this.items = const [],
    this.total = 0,
    this.discount = 0,
    this.deliveryCharge = 0,
    this.finalTotal = 0,
    this.appliedCoupon,
  });

  final List<CartItem> items;
  final double total;
  final double discount;
  final double deliveryCharge;
  final double finalTotal;
  final AppliedCoupon? appliedCoupon;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, total, discount, finalTotal, appliedCoupon];
}

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.preparation,
    required this.imageUrl,
    required this.unit,
    this.stock = 0,
  });

  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? preparation;
  final String imageUrl;
  final String unit;
  final int stock;

  double get subtotal => price * quantity;

  @override
  List<Object?> get props => [productId, quantity, preparation];
}

class AppliedCoupon extends Equatable {
  const AppliedCoupon({
    required this.code,
    required this.offerId,
    required this.discount,
  });

  final String code;
  final String offerId;
  final double discount;

  @override
  List<Object?> get props => [code, offerId];
}
