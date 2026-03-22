import 'package:get/get.dart';
import '../../data/repositories/agent_repository.dart';

class AgentController extends GetxController {
  final _repo = AgentRepository();
  final isLoading = false.obs;
  
  final agentProfile = Rxn<Map<String, dynamic>>();
  final isOnline = false.obs;
  
  final currentAssignment = Rxn<Map<String, dynamic>>();
  final earningsSummary = Rxn<Map<String, dynamic>>();
  final assignments = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      final profile = await _repo.getProfile();
      agentProfile.value = profile['data'];
      isOnline.value = profile['data']['status'] == 'available';
      
      final current = await _repo.getCurrentAssignment();
      currentAssignment.value = current['data'];
      
      final earnings = await _repo.getEarnings();
      earningsSummary.value = earnings['data'];
      
      final all = await _repo.getAssignments();
      assignments.assignAll(all);
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus() async {
    try {
      await _repo.updateStatus(!isOnline.value);
      isOnline.toggle();
    } catch (_) {}
  }

  Future<void> updateDeliveryStatus(String assignmentId, String status) async {
    try {
      await _repo.updateAssignmentStatus(assignmentId, status);
      fetchInitialData();
      Get.snackbar('Success', 'Delivery status updated');
    } catch (_) {}
  }
}
