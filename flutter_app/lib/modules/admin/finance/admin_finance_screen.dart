import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'admin_payouts_screen.dart';
import 'commission_settings_screen.dart';
import '../merchants/merchant_analytics_screen.dart';
import '../orders/admin_order_detail_screen.dart';
import '../widgets/admin_drawer.dart';
import '../admin_controller.dart';

class AdminFinanceScreen extends StatelessWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F1),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A4D2E), Color(0xFF2D7A4A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            return IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            );
                          }
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Financial Reports',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin › Finance › Reports',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Obx(() {
              final stats = controller.stats.value;
              final totalRevenue = stats['totalRevenue']?.toString() ?? '0';
              final platformFee = stats['platformFee']?.toString() ?? '0';
              final totalPayouts = stats['totalPayouts']?.toString() ?? '0';
              final netProfit = stats['netProfit']?.toString() ?? '0';

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Total Rev',
                          value: '₹$totalRevenue',
                          icon: Icons.trending_up,
                          color: const Color(0xFF1F5C35),
                          onTap: () {
                            Get.to(() => const MerchantAnalyticsScreen());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Platform Fee',
                          value: '₹$platformFee',
                          icon: Icons.pie_chart_outline,
                          color: Colors.blue,
                          onTap: () {
                            Get.to(() => const CommissionSettingsScreen());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Payouts',
                          value: '₹$totalPayouts',
                          icon: Icons.payments_outlined,
                          color: Colors.orange,
                          onTap: () {
                            Get.to(() => const AdminPayoutsScreen());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Net Profit',
                          value: '₹$netProfit',
                          icon: Icons.account_balance_outlined,
                          color: Colors.purple,
                          onTap: () {
                            Get.to(() => const MerchantAnalyticsScreen());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Transaction History
                  const Text(
                    'Recent Payout History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x201F5C35),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: controller.payouts.where((p) => p['status'] == 'Completed').take(5).map((p) {
                        final name = p['merchant']?['name'] ?? p['agent']?['name'] ?? 'Unknown';
                        final amount = p['amount']?.toString() ?? '0';
                        final date = p['updatedAt']?.toString().split('T')[0] ?? 'N/A';
                        return Column(
                          children: [
                            _buildTransactionRow('Payout to $name', '-₹$amount', date, isCredit: false, onTap: () {
                              Get.to(() => const AdminPayoutsScreen());
                            }),
                            if (p != controller.payouts.where((p) => p['status'] == 'Completed').take(5).last)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(color: Color(0xFFE8E8E8), height: 1),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  if (controller.payouts.where((p) => p['status'] == 'Completed').isEmpty)
                    const Center(child: Text('No transaction history available.')),
                  
                  const SizedBox(height: 24),

                  // Request Payout Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.snackbar(
                          'Report Exported',
                          'GST Report has been downloaded to your device.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B4332),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x401F5C35),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '📊 Export GST Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          Get.snackbar(
            'Analytics',
            'Viewing detailed analytics for $title',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x201F5C35),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9C9B99), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String title, String amount, String date, {required bool isCredit, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          Get.snackbar(
            'Transaction Details',
            'Viewing details for $title',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF9C9B99))),
                ],
              ),
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCredit ? const Color(0xFF1A4D2E) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}