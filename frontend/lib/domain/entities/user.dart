import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.dietaryPreferences = const [],
    this.allergies = const [],
    this.isPremium = false,
    this.premiumExpiresAt,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'bronze',
    this.walletBalance = 0,
    this.referralCode,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final int loyaltyPoints;
  final String loyaltyTier;
  final double walletBalance;
  final String? referralCode;

  @override
  List<Object?> get props => [id, name, email, phone];
}
