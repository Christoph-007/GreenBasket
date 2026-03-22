import '../providers/api_provider.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _api.post('/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await _api.post('/auth/resend-otp', data: {'email': email});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response =
        await _api.post('/auth/forgot-password', data: {'email': email});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await _api.post('/auth/reset-password', data: {
      'token': token,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> getProfile() async {
    final response = await _api.get('/user/profile');
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data']);
  }
}
