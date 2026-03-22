import 'package:get/get.dart';
import '../data/providers/api_provider.dart';
import '../data/services/storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/order_repository.dart';
import '../modules/auth/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiProvider(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
    Get.put(ProductRepository(), permanent: true);
    Get.put(OrderRepository(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
