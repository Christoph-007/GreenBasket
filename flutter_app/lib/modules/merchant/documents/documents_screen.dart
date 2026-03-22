import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

enum DocStatus { verified, pending, rejected, notUploaded }

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  // Mock document data — TODO: fetch from API
  static final List<Map<String, dynamic>> _documents = [
    {
      'type': 'FSSAI License',
      'subtitle': 'Food Safety & Standards Authority',
      'icon': Icons.verified_outlined,
      'status': DocStatus.verified,
      'uploadDate': 'Jan 15, 2024',
      'expiryDate': 'Jan 14, 2026',
      'docNumber': 'FSSAI-12345678901234',
    },
    {
      'type': 'GST Certificate',
      'subtitle': 'Goods & Services Tax Registration',
      'icon': Icons.receipt_long_outlined,
      'status': DocStatus.verified,
      'uploadDate': 'Jan 15, 2024',
      'expiryDate': 'Lifetime',
      'docNumber': '29AAAAA0000A1Z5',
    },
    {
      'type': 'Trade License',
      'subtitle': 'Municipal Corporation License',
      'icon': Icons.store_outlined,
      'status': DocStatus.pending,
      'uploadDate': 'Mar 10, 2024',
      'expiryDate': 'Mar 31, 2025',
      'docNumber': null,
    },
    {
      'type': 'Organic Certification',
      'subtitle': 'Organic Farming Certificate',
      'icon': Icons.eco_outlined,
      'status': DocStatus.notUploaded,
      'uploadDate': null,
      'expiryDate': null,
      'docNumber': null,
    },
  ];

  Color _statusColor(DocStatus s) {
    switch (s) {
      case DocStatus.verified:
        return AppColors.success;
      case DocStatus.pending:
        return AppColors.warning;
      case DocStatus.rejected:
        return AppColors.error;
      case DocStatus.notUploaded:
        return AppColors.textHint;
    }
  }

  String _statusLabel(DocStatus s) {
    switch (s) {
      case DocStatus.verified:
        return 'Verified';
      case DocStatus.pending:
        return 'Pending Review';
      case DocStatus.rejected:
        return 'Rejected';
      case DocStatus.notUploaded:
        return 'Not Uploaded';
    }
  }

  IconData _statusIcon(DocStatus s) {
    switch (s) {
      case DocStatus.verified:
        return Icons.check_circle_outline;
      case DocStatus.pending:
        return Icons.schedule_outlined;
      case DocStatus.rejected:
        return Icons.cancel_outlined;
      case DocStatus.notUploaded:
        return Icons.upload_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifiedCount =
        _documents.where((d) => d['status'] == DocStatus.verified).length;
    final pendingCount =
        _documents.where((d) => d['status'] == DocStatus.pending).length;
    final rejectedCount =
        _documents.where((d) => d['status'] == DocStatus.rejected).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Documents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Status',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _summaryChip(
                          '$verifiedCount Verified', AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      _summaryChip(
                          '$pendingCount Pending', AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      _summaryChip(
                          '$rejectedCount Rejected', AppColors.error),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: verifiedCount / _documents.length,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$verifiedCount of ${_documents.length} documents verified',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Documents', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),

            ..._documents.map((doc) => _buildDocumentCard(context, doc)),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }

  Widget _buildDocumentCard(
      BuildContext context, Map<String, dynamic> doc) {
    final status = doc['status'] as DocStatus;
    final color = _statusColor(status);
    final isUploaded = status != DocStatus.notUploaded;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: status == DocStatus.rejected
              ? AppColors.error.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(doc['icon'] as IconData,
                          color: color, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['type'] as String,
                              style: AppTextStyles.titleMedium),
                          Text(doc['subtitle'] as String,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status),
                              size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(_statusLabel(status),
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: color)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isUploaded) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (doc['docNumber'] != null) ...[
                        Expanded(
                          child: _infoItem(
                              'Document No.', doc['docNumber'] as String),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: _infoItem('Uploaded',
                            doc['uploadDate'] as String? ?? '-'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _infoItem(
                            'Expiry', doc['expiryDate'] as String? ?? '-'),
                      ),
                    ],
                  ),
                  if (status == DocStatus.rejected) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.error),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Document rejected: Please upload a clearer copy',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                if (isUploaded)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: open document viewer
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm)),
                    ),
                  ),
                if (isUploaded) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(
                        '/merchant/documents/upload',
                        arguments: {'type': doc['type']}),
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: Text(
                        isUploaded ? 'Re-Upload' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        Text(value,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
