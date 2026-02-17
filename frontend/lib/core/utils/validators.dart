import 'package:greenbasket/core/constants/app_strings.dart';

/// Client-side form validators returning null (valid) or error message.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final _phoneRegex = RegExp(r'^[0-9]{10}$');
  static final _pincodeRegex = RegExp(r'^[0-9]{6}$');
  static final _otpRegex = RegExp(r'^[0-9]{6}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (!_emailRegex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.requiredField;
    if (value.length < 6) return AppStrings.passwordTooShort;
    if (!RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
      return AppStrings.passwordRequirements;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final base = Validators.password(value);
    if (base != null) return base;
    if (value != password) return AppStrings.passwordsMismatch;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (value.trim().length < 2) return AppStrings.nameTooShort;
    if (value.trim().length > 50) return AppStrings.nameTooLong;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (!_phoneRegex.hasMatch(value.trim())) return AppStrings.invalidPhone;
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (!_pincodeRegex.hasMatch(value.trim())) return AppStrings.invalidPincode;
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (!_otpRegex.hasMatch(value.trim())) return AppStrings.invalidOtp;
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    return null;
  }

  /// Returns a password strength score: 0-2 weak, 3-4 medium, 5+ strong.
  static int passwordStrength(String value) {
    int score = 0;
    if (value.length >= 6) score++;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
    return score;
  }
}
