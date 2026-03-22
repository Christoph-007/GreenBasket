import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'package:greenbasket_app/config/routes.dart';
import 'package:greenbasket_app/modules/auth/auth_controller.dart';
import '../analytics/merchant_analytics_screen.dart';
import '../documents/documents_screen.dart';
import '../documents/upload_document_screen.dart';
import '../financial/financial_screen.dart';
import '../financial/payouts_screen.dart';
import '../offers/create_offer_screen.dart';
import '../offers/offer_analytics_screen.dart';
import '../offers/offers_screen.dart';
import '../orders/merchant_order_detail_screen.dart';
import '../products/add_product_screen.dart';
import '../products/bulk_upload_screen.dart';
import '../products/edit_product_screen.dart';
import '../products/product_stock_screen.dart';
import '../settings/store_settings_screen.dart';
import '../settings/subscriptions_screen.dart';
import '../zones/delivery_zones_screen.dart';
import '../zones/edit_zone_screen.dart';

class MerchantDrawer extends StatelessWidget {
  const MerchantDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.primary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                       child: const Text('No special instructions provided',
                          style: AppTextStyles.bodyMedium),
                      ),
                      const SizedBox(height: 12),
                      Text('Merchant Portal', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                _drawerGroup('Orders & Products'),
                _drawerItem(Icons.list_alt, 'View Orders', () => Get.toNamed(Routes.merchantOrders)),
                _drawerItem(Icons.add_box, 'Add Product', () => Get.toNamed(Routes.merchantAddProduct)),
                _drawerItem(Icons.upload_file, 'Bulk Upload', () => Get.toNamed(Routes.merchantBulkUpload)),
                _drawerItem(Icons.edit, 'Inventory', () => Get.toNamed(Routes.merchantProducts)),

                _drawerGroup('Finance & Analytics'),
                _drawerItem(Icons.account_balance_wallet, 'Financial', () => Get.to(() => const FinancialScreen())),
                _drawerItem(Icons.payments, 'Payouts', () => Get.to(() => const PayoutsScreen())),
                _drawerItem(Icons.bar_chart, 'Offer Analytics', () => Get.to(() => const OfferAnalyticsScreen())),
                
                _drawerGroup('Offers & Zones'),
                _drawerItem(Icons.local_offer, 'Offers', () => Get.to(() => const OffersScreen())),
                _drawerItem(Icons.add_circle, 'Create Offer', () => Get.to(() => const CreateOfferScreen())),
                _drawerItem(Icons.map, 'Delivery Zones', () => Get.to(() => const DeliveryZonesScreen())),
                _drawerItem(Icons.edit_location, 'Edit Zone', () => Get.to(() => const EditZoneScreen())),

                _drawerGroup('Settings & profile'),
                _drawerItem(Icons.store, 'Store Settings', () => Get.to(() => const StoreSettingsScreen())),
                _drawerItem(Icons.subscriptions, 'Subscriptions', () => Get.to(() => const SubscriptionsScreen())),
                _drawerItem(Icons.file_copy, 'Documents', () => Get.to(() => const DocumentsScreen())),
                _drawerItem(Icons.upload, 'Upload Document', () => Get.to(() => const UploadDocumentScreen())),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              Get.back(); // close drawer
              Get.find<AuthController>().logout();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _drawerGroup(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(title, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      onTap: () {
        Get.back();
        onTap();
      },
      dense: true,
    );
  }
}
