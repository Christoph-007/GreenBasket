import 'package:get/get.dart';
import '../../../data/repositories/merchant_repository.dart';

class MerchantAnalyticsController extends GetxController {
  final _repo = MerchantRepository();
  final isLoading = false.obs;
  
  final monthlyOverview = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      isLoading.value = true;
      final data = await _repo.getAnalytics();
      monthlyOverview.value = data['data'];
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }
}
