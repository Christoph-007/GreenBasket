import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class VerifyMerchantScreen extends StatefulWidget {
  const VerifyMerchantScreen({super.key});

  @override
  State<VerifyMerchantScreen> createState() => _VerifyMerchantScreenState();
}

class _VerifyMerchantScreenState extends State<VerifyMerchantScreen> {
  final _notesController = TextEditingController();
  bool _fssaiVerified = false;
  bool _gstVerified = false;
  bool _licenseVerified = false;
  String? _viewingDoc;

  // Mock merchant data — replace with API call
  final _merchant = {
    'businessName': 'Fresh Farms Organics',
    'ownerName': 'Rahul Gupta',
    'email': 'rahul@freshfarms.in',
    'phone': '+91 87654 32109',
    'address': '42 MG Road, Bangalore, Karnataka 560001',
    'registeredOn': '15 Mar 2024',
  };

  void _showDocumentViewer(String docName) {
    setState(() => _viewingDoc = docName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(docName, style: AppTextStyles.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.md),
                    Text('Document Preview', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.sm),
                    // TODO: Load actual document from API/storage
                    Text('Tap to open full document', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(bool isApprove) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text(
          isApprove ? 'Approve Merchant?' : 'Reject Merchant?',
          style: AppTextStyles.titleLarge,
        ),
        content: Text(
          isApprove
              ? 'Are you sure you want to approve Fresh Farms Organics? They will be able to list products.'
              : 'Are you sure you want to reject Fresh Farms Organics? Please provide a rejection reason.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.success : AppColors.error,
            ),
            onPressed: () {
              // TODO: Call API to approve/reject merchant
              Navigator.pop(ctx);
              Get.back();
              Get.snackbar(
                isApprove ? 'Merchant Approved' : 'Merchant Rejected',
                'Fresh Farms Organics has been ${isApprove ? 'approved' : 'rejected'}.',
                backgroundColor: isApprove ? AppColors.success : AppColors.error,
                colorText: Colors.white,
              );
            },
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allVerified = _fssaiVerified && _gstVerified && _licenseVerified;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Merchant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessInfo(),
            const SizedBox(height: AppSpacing.md),
            _buildDocumentsSection(),
            const SizedBox(height: AppSpacing.md),
            _buildChecklist(),
            const SizedBox(height: AppSpacing.md),
            _buildNotesField(),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(allVerified),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.store_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_merchant['businessName']!, style: AppTextStyles.titleLarge),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Pending Verification',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            _infoRow('Owner', _merchant['ownerName']!),
            _infoRow('Email', _merchant['email']!),
            _infoRow('Phone', _merchant['phone']!),
            _infoRow('Address', _merchant['address']!),
            _infoRow('Registered On', _merchant['registeredOn']!),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documents', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _documentRow('FSSAI License', 'FSSAI-2024-38291', true),
            const Divider(),
            _documentRow('GST Certificate', 'GST27ABCDE1234F1Z5', true),
            const Divider(),
            _documentRow('Trade License', 'TL/BLR/2024/5678', false),
          ],
        ),
      ),
    );
  }

  Widget _documentRow(String name, String docId, bool isUploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.upload_file : Icons.error_outline,
            color: isUploaded ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge),
                Text(
                  isUploaded ? docId : 'Not uploaded',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isUploaded ? AppColors.textSecondary : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          if (isUploaded)
            OutlinedButton(
              onPressed: () => _showDocumentViewer(name),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('View'),
            ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verification Checklist', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            _checkItem('FSSAI document is valid and not expired', _fssaiVerified, (v) => setState(() => _fssaiVerified = v!)),
            _checkItem('GST certificate matches business name', _gstVerified, (v) => setState(() => _gstVerified = v!)),
            _checkItem('Trade license is current and active', _licenseVerified, (v) => setState(() => _licenseVerified = v!)),
          ],
        ),
      ),
    );
  }

  Widget _checkItem(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rejection Reason / Notes', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter reason for rejection or any notes...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool allVerified) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showActionDialog(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Reject'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: allVerified ? () => _showActionDialog(true) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Approve'),
          ),
        ),
      ],
    );
  }
}
