import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';

class AuthController extends GetxController {
  final _repo = AuthRepository();
  final _storage = StorageService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final user = Rxn<UserModel>();

  bool get isLoggedIn => _storage.isLoggedIn;
  String get role => _storage.role ?? AppConstants.roleCustomer;

  @override
  void onInit() {
    super.onInit();
    user.value = _storage.user;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.login(email: email, password: password);
      if (result['success'] == true) {
        // Corrected: Backend sends token and user at top level
        _storage.saveToken(result['token'] ?? result['data']?['token']);
        final u = UserModel.fromJson(result['user'] ?? result['data']?['user'] ?? {});
        _storage.saveUser(u);
        _storage.saveRole(u.role);
        user.value = u;
        _navigateByRole(u.role);
      } else {
        errorMessage.value = result['message'] ?? 'Login failed';
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['message'] ?? 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      if (result['success'] == true) {
        Get.toNamed(Routes.otp, arguments: {'email': email, 'role': role});
      } else {
        errorMessage.value = result['message'] ?? 'Registration failed';
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['message'] ?? 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.verifyOtp(email: email, otp: otp);
      if (result['success'] == true) {
        // Corrected: Backend sends token and user at top level
        _storage.saveToken(result['token'] ?? result['data']?['token']);
        final u = UserModel.fromJson(result['user'] ?? result['data']?['user'] ?? {});
        _storage.saveUser(u);
        _storage.saveRole(u.role);
        user.value = u;
        _navigateByRole(u.role);
      } else {
        errorMessage.value = result['message'] ?? 'Invalid OTP';
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['message'] ?? 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _repo.resendOtp(email);
      Get.snackbar('OTP Sent', 'A new OTP has been sent to your email.');
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['message'] ?? 'Failed to resend OTP';
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.forgotPassword(email);
      if (result['success'] == true) {
        Get.snackbar(
          'Email Sent',
          'Password reset link has been sent to $email',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage.value = result['message'] ?? 'Failed to send reset email';
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['message'] ?? 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.clearAll();
    user.value = null;
    Get.offAllNamed(Routes.login);
  }

  void _navigateByRole(String role) {
    switch (role) {
      case AppConstants.roleCustomer:
        Get.offAllNamed(Routes.customerHome);
        break;
      case AppConstants.roleMerchant:
        Get.offAllNamed(Routes.merchantDashboard);
        break;
      case AppConstants.roleAdmin:
        Get.offAllNamed(Routes.adminDashboard);
        break;
      case AppConstants.roleAgent:
        Get.offAllNamed(Routes.agentCurrentJob);
        break;
      default:
        Get.offAllNamed(Routes.customerHome);
    }
  }
}
