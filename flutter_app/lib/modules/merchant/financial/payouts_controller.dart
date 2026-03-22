import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../data/repositories/merchant_repository.dart';

class PayoutsController extends GetxController {
  final _repo = MerchantRepository();
  final isLoading = false.obs;
  final isRequesting = false.obs;

  final availableBalance = 0.0.obs;
  final totalPaidOut = 0.0.obs;
  final nextPayoutDate = ''.obs;
  final bankName = ''.obs;
  final bankLast4 = ''.obs;
  final payouts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayouts();
  }

  Future<void> fetchPayouts() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repo.getPayoutSummary(),
        _repo.getPayouts(),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final data = summary['data'] ?? summary;
      availableBalance.value =
          (data['availableBalance'] ?? 0).toDouble();
      totalPaidOut.value = (data['totalPaidOut'] ?? 0).toDouble();
      nextPayoutDate.value = data['nextPayoutDate'] ?? '';
      bankName.value = data['bankName'] ?? '';
      bankLast4.value = data['bankLast4'] ?? '';

      payouts.assignAll(results[1] as List<Map<String, dynamic>>);
    } catch (_) {
      availableBalance.value = 0;
      totalPaidOut.value = 0;
      nextPayoutDate.value = '';
      bankName.value = '';
      bankLast4.value = '';
      payouts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestPayout() async {
    try {
      isRequesting.value = true;
      final result = await _repo.requestPayout();
      if (result['success'] == true) {
        Get.snackbar(
          'Payout Requested',
          'Your payout will be credited in 2–3 business days',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchPayouts();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Payout request failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not process payout request',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isRequesting.value = false;
    }
  }
}
