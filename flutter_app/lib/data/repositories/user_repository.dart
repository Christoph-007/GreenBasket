import '../providers/api_provider.dart';
import '../models/user_model.dart';

class UserRepository {
  final _api = ApiProvider();

  Future<UserModel> getProfile() async {
    final response = await _api.get('/user/profile');
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data']);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.put('/user/profile', data: data);
  }

  // Wallet
  Future<double> getWalletBalance() async {
    final response = await _api.get('/wallet/balance');
    final data = response.data as Map<String, dynamic>;
    return (data['data']['balance'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getWalletTransactions() async {
    final response = await _api.get('/wallet/transactions');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data']);
  }

  // Loyalty
  Future<Map<String, dynamic>> getLoyaltyInfo() async {
    final response = await _api.get('/loyalty');
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  // Referral
  Future<Map<String, dynamic>> getReferralInfo() async {
    final response = await _api.get('/referral');
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  // Gift Cards
  Future<List<Map<String, dynamic>>> getGiftCards() async {
    final response = await _api.get('/gift-cards');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data']);
  }

  Future<void> redeemGiftCard(String code) async {
    await _api.post('/gift-cards/redeem', data: {'code': code});
  }

  // Notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _api.get('/notifications');
    final data = response.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['data']);
  }

  Future<void> markNotificationAsRead(String id) async {
    await _api.put('/notifications/$id/read');
  }
}
