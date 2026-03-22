class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? deliveryAgentName;
  final String? deliveryAgentPhone;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.estimatedDelivery,
    this.deliveryAgentName,
    this.deliveryAgentPhone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'pending',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      deliveryAddress: AddressModel.fromJson(json['deliveryAddress'] ?? {}),
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.tryParse(json['estimatedDelivery'])
          : null,
      deliveryAgentName: json['deliveryAgent']?['name'],
      deliveryAgentPhone: json['deliveryAgent']?['phone'],
    );
  }

  bool get isActive => [
        'pending',
        'confirmed',
        'preparing',
        'dispatched',
      ].contains(status);
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? preparationOption;
  final String merchantId;
  final String merchantName;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.preparationOption,
    required this.merchantId,
    required this.merchantName,
  });

  double get itemTotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product']?['_id'] ?? json['productId'] ?? '',
      productName: json['product']?['name'] ?? json['productName'] ?? '',
      productImage: json['product']?['images']?[0] ?? json['productImage'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      preparationOption: json['preparationOption'],
      merchantId: json['merchant']?['_id'] ?? json['merchantId'] ?? '',
      merchantName:
          json['merchant']?['businessName'] ?? json['merchantName'] ?? '',
    );
  }
}

class AddressModel {
  final String id;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  String get fullAddress =>
      '$line1${line2 != null ? ', $line2' : ''}, $city, $state - $pincode';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      label: json['label'] ?? 'Home',
      line1: json['line1'] ?? json['address'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      isDefault: json['isDefault'] ?? false,
      latitude: json['location']?['coordinates']?[1]?.toDouble(),
      longitude: json['location']?['coordinates']?[0]?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'isDefault': isDefault,
      };
}

class CartItemModel {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  int quantity;
  final String merchantId;
  final String merchantName;
  final String? preparationOption;
  final String unit;

  CartItemModel({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.merchantId,
    required this.merchantName,
    this.preparationOption,
    required this.unit,
  });

  double get itemTotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product']?['_id'] ?? json['productId'] ?? '',
      productName: json['product']?['name'] ?? json['productName'] ?? '',
      productImage: json['product']?['images']?[0],
      price: (json['price'] ?? json['product']?['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      merchantId: json['product']?['merchant']?['_id'] ?? '',
      merchantName: json['product']?['merchant']?['businessName'] ?? '',
      preparationOption: json['preparationOption'],
      unit: json['product']?['unit'] ?? 'kg',
    );
  }
}
