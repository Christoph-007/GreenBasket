import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/repositories/merchant_repository.dart';

class MerchantAnalyticsController extends GetxController {
  final _repo = MerchantRepository();
  final isLoading = false.obs;

  // Top-level summary cards
  final totalRevenue = 0.0.obs;
  final totalOrders = 0.obs;
  final avgOrderValue = 0.0.obs;
  final returnRate = 0.0.obs;

  // Chart data
  final revenueChartValues = <double>[].obs;
  final revenueChartLabels = <String>[].obs;

  // Top products
  final topProducts = <Map<String, dynamic>>[].obs;

  // Raw overview (for any extra fields the screen might need)
  final monthlyOverview = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      isLoading.value = true;
      final response = await _repo.getAnalytics();
      final data = response['data'] ?? response;

      totalRevenue.value =
          ((data['totalRevenue'] ?? data['revenue'] ?? 0) as num).toDouble();
      totalOrders.value = data['totalOrders'] ?? data['orders'] ?? 0;
      avgOrderValue.value =
          ((data['avgOrderValue'] ?? data['averageOrder'] ?? 0) as num)
              .toDouble();
      returnRate.value =
          ((data['returnRate'] ?? 0) as num).toDouble();

      // Chart
      final rawChart =
          data['revenueChart'] as List<dynamic>? ?? [];
      if (rawChart.isNotEmpty) {
        final maxVal = rawChart
            .map((v) => ((v['value'] ?? v) as num).toDouble())
            .reduce((a, b) => a > b ? a : b);
        revenueChartValues.value = rawChart
            .map((v) => maxVal > 0
                ? ((v['value'] ?? v) as num).toDouble() / maxVal
                : 0.0)
            .toList();
        revenueChartLabels.value = rawChart
            .map((v) => (v['label'] ?? '').toString())
            .toList();
      } else {
        revenueChartValues.value = [];
        revenueChartLabels.value = [];
      }

      // Top products
      final products =
          data['topProducts'] as List<dynamic>? ?? [];
      topProducts.assignAll(
          products.map((e) => Map<String, dynamic>.from(e)).toList());

      monthlyOverview.value = data;
    } catch (e) {
      debugPrint('[MerchantAnalyticsController] fetchAnalytics error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
