import 'package:get/get.dart';

class MerchantController extends GetxController {
  final isLoading = false.obs;
  final isStoreOpen = true.obs;
  
  final revenue = "₹4,820".obs;
  final orderCount = 23.obs;
  final rating = 4.8.obs;
  
  final newOrders = [
    {
      'id': '1042',
      'customer': 'Rahul Kumar',
      'items': '2x Tomato, 1x Spinach',
      'amount': '₹450',
      'time': '5 min ago'
    },
    {
      'id': '1041',
      'customer': 'Sonia Gandhi',
      'items': '5x Organic Apples',
      'amount': '₹1,200',
      'time': '12 min ago'
    },
  ].obs;

  void toggleStoreStatus(bool? val) {
    if (val != null) isStoreOpen.value = val;
  }
}
