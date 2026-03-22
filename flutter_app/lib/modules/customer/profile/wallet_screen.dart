import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/gb_app_bar.dart';
import '../../../widgets/common/gb_loader.dart';
import '../../../widgets/common/empty_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _api = ApiProvider();
  double _balance = 0;
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await _api.get('/wallet');
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _balance = (data['data']?['balance'] ?? 0).toDouble();
        _transactions =
            (data['data']?['transactions'] as List<dynamic>?) ?? [];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GBAppBar(title: 'My Wallet'),
      body: _isLoading
          ? const GBLoader()
          : Column(
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Balance',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppHelpers.formatCurrency(_balance),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text('Transaction History',
                      style: AppTextStyles.titleLarge),
                ),
                Expanded(
                  child: _transactions.isEmpty
                      ? const EmptyState(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No transactions yet',
                          message: 'Your wallet transactions will appear here',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemCount: _transactions.length,
                          itemBuilder: (context, i) {
                            final tx = _transactions[i];
                            final isCredit = (tx['type'] ?? '') == 'credit';
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCredit
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.error.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isCredit
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 18,
                                ),
                              ),
                              title:
                                  Text(tx['description'] ?? 'Transaction'),
                              subtitle: Text(
                                  AppHelpers.formatDate(DateTime.tryParse(
                                          tx['createdAt'] ?? '') ??
                                      DateTime.now())),
                              trailing: Text(
                                '${isCredit ? '+' : '-'}${AppHelpers.formatCurrency((tx['amount'] ?? 0).toDouble())}',
                                style: TextStyle(
                                  color: isCredit
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
