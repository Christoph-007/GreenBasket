import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import 'admin_order_detail_screen.dart';
import '../widgets/admin_drawer.dart';

import '../admin_controller.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final controller = Get.find<AdminController>();
  final RxString _selectedFilter = 'All'.obs;

  @override
  Widget build(BuildContext context) {
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
                          'All Orders',
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
                      child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin › Orders',
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
              final filteredOrders = controller.orders.where((o) {
                if (_selectedFilter.value == 'All') return true;
                return (o['status']?.toString().toLowerCase() ?? '') == _selectedFilter.value.toLowerCase();
              }).toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPill('All'),
                        const SizedBox(width: 8),
                        _buildPill('Pending'),
                        const SizedBox(width: 8),
                        _buildPill('Processing'),
                        const SizedBox(width: 8),
                        _buildPill('In Transit'),
                        const SizedBox(width: 8),
                        _buildPill('Delivered'),
                        const SizedBox(width: 8),
                        _buildPill('Cancelled'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Cards
                  if (filteredOrders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('No orders found', style: TextStyle(color: AppColors.textHint)),
                      ),
                    )
                  else
                    ...filteredOrders.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildOrderCard(order as Map<String, dynamic>),
                    )).toList(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String title) {
    return Obx(() {
      bool isActive = _selectedFilter.value == title;
      return GestureDetector(
        onTap: () => _selectedFilter.value = title,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: isActive ? null : Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFD97706);
      case 'processing': return Colors.orange;
      case 'in transit': return Colors.blue;
      case 'delivered': return const Color(0xFF1A4D2E);
      case 'cancelled': return const Color(0xFFDC2626);
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'Pending';
    final orderId = order['orderNumber'] ?? order['_id'] ?? order['id'] ?? 'N/A';
    final customerName = order['customer']?['name'] ?? 'Guest';
    final itemsCount = (order['items'] as List?)?.length ?? 0;
    final total = order['totalAmount'] ?? order['total'] ?? '0';
    final date = order['createdAt']?.toString().split('T')[0] ?? 'N/A';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.to(() => const AdminOrderDetailScreen());
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: _getStatusColor(status), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$customerName · $itemsCount items · ₹$total',
                style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Color(0xFF9C9B99)),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: const TextStyle(color: Color(0xFF9C9B99), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}