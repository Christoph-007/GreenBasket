import 'package:greenbasket_app/data/providers/api_provider.dart';

class AgentRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/agents/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('/agents/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateStatus(bool isOnline) async {
    await _api.put('/agents/me/status', data: {
      'status': isOnline ? 'available' : 'offline',
    });
  }

  Future<Map<String, dynamic>> getCurrentAssignment() async {
    final response = await _api.get('/agents/assignments/current');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAssignments() async {
    final response = await _api.get('/agents/assignments');
    final data = response.data as Map<String, dynamic>;
    return data['assignments'] as List<dynamic>? ?? [];
  }

  Future<void> updateAssignmentStatus(String id, String status) async {
    await _api.put('/agents/assignments/$id/status', data: {
      'status': status,
    });
  }

  Future<Map<String, dynamic>> getEarnings() async {
    final response = await _api.get('/agents/earnings');
    return response.data as Map<String, dynamic>;
  }
}
