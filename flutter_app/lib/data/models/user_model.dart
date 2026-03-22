class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final bool isVerified;
  final double walletBalance;
  final int loyaltyPoints;
  final String loyaltyTier;
  final String? referralCode;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.isVerified = false,
    this.walletBalance = 0.0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'bronze',
    this.referralCode,
    this.isPremium = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      avatar: json['avatar'],
      isVerified: json['isVerified'] ?? false,
      walletBalance: (json['wallet']?['balance'] ?? 0).toDouble(),
      loyaltyPoints: json['loyalty']?['points'] ?? 0,
      loyaltyTier: json['loyalty']?['tier'] ?? 'bronze',
      referralCode: json['referralCode'],
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'avatar': avatar,
        'isVerified': isVerified,
        'walletBalance': walletBalance,
        'loyaltyPoints': loyaltyPoints,
        'loyaltyTier': loyaltyTier,
        'referralCode': referralCode,
        'isPremium': isPremium,
      };

  UserModel copyWith({
    String? name,
    String? avatar,
    String? role,
    double? walletBalance,
    int? loyaltyPoints,
    String? loyaltyTier,
    bool? isPremium,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      referralCode: referralCode,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
