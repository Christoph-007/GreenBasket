import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../config/constants.dart';
import '../models/user_model.dart';

class StorageService {
  final _box = GetStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<void> init() => GetStorage.init();

  // Token
  String? get token => _box.read(AppConstants.tokenKey);
  void saveToken(String token) => _box.write(AppConstants.tokenKey, token);
  void clearToken() => _box.remove(AppConstants.tokenKey);

  // User
  UserModel? get user {
    final json = _box.read(AppConstants.userKey);
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  void saveUser(UserModel user) =>
      _box.write(AppConstants.userKey, jsonEncode(user.toJson()));
  void clearUser() => _box.remove(AppConstants.userKey);

  // Role
  String? get role => _box.read(AppConstants.roleKey);
  void saveRole(String role) => _box.write(AppConstants.roleKey, role);

  // Onboarding
  bool get isOnboarded => _box.read(AppConstants.onboardedKey) ?? false;
  void setOnboarded() => _box.write(AppConstants.onboardedKey, true);

  bool get isLoggedIn => token != null;

  void clearAll() => _box.erase();
}
