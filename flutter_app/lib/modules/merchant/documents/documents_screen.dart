import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';
import '../../../data/repositories/merchant_repository.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _repo = MerchantRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    try {
      final docs = await _repo.getDocuments();
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return AppColors.success;
      case 'pending':
      case 'under_review':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return 'Verified';
      case 'pending':
      case 'under_review':
        return 'Pending Review';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not Uploaded';
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return Icons.check_circle_outline;
      case 'pending':
      case 'under_review':
        return Icons.schedule_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.upload_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final verifiedCount = _documents
        .where((d) =>
            (d['status'] ?? '').toLowerCase() == 'verified' ||
            (d['status'] ?? '').toLowerCase() == 'approved')
        .length;
    final pendingCount = _documents
        .where((d) =>
            (d['status'] ?? '').toLowerCase() == 'pending' ||
            (d['status'] ?? '').toLowerCase() == 'under_review')
        .length;
    final rejectedCount = _documents
        .where((d) => (d['status'] ?? '').toLowerCase() == 'rejected')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Documents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchDocuments();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDocuments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        _summaryChip('$verifiedCount Verified',
                            AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        _summaryChip(
                            '$pendingCount Pending', AppColors.warning),
                        const SizedBox(width: AppSpacing.sm),
                        _summaryChip(
                            '$rejectedCount Rejected', AppColors.error),
                      ],
                    ),
                    if (_documents.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Documents', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),

              if (_documents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No documents found. Upload your compliance documents.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium),
                  ),
                )
              else
                ..._documents.map(
                    (doc) => _buildDocumentCard(context, doc)),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Get.toNamed('/merchant/documents/upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Document'),
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
      child:
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }

  Widget _buildDocumentCard(
      BuildContext context, Map<String, dynamic> doc) {
    final status = (doc['status'] ?? 'not_uploaded').toString();
    final color = _statusColor(status);
    final docType = doc['type'] ?? doc['documentType'] ?? 'Document';
    final subtitle = doc['subtitle'] ?? doc['description'] ?? '';
    final isUploaded = status.toLowerCase() != 'not_uploaded' &&
        status.toLowerCase() != 'not uploaded';
    final docNumber = doc['docNumber'] ?? doc['documentNumber'];
    final uploadDate = doc['uploadDate'] ?? doc['uploadedAt'];
    final expiryDate = doc['expiryDate'] ?? doc['expiresAt'] ?? 'N/A';
    final rejectionReason =
        doc['rejectionReason'] ?? doc['reason'];

    IconData docIcon;
    switch (docType.toLowerCase()) {
      case 'fssai':
      case 'fssai license':
        docIcon = Icons.verified_outlined;
        break;
      case 'gst':
      case 'gst certificate':
        docIcon = Icons.receipt_long_outlined;
        break;
      case 'organic':
      case 'organic certification':
        docIcon = Icons.eco_outlined;
        break;
      default:
        docIcon = Icons.description_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: status.toLowerCase() == 'rejected'
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
                      child: Icon(docIcon, color: color, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(docType,
                              style: AppTextStyles.titleMedium),
                          if (subtitle.isNotEmpty)
                            Text(subtitle,
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
                      if (docNumber != null) ...[
                        Expanded(
                          child: _infoItem('Document No.', '$docNumber'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      if (uploadDate != null)
                        Expanded(
                          child: _infoItem('Uploaded', '$uploadDate'),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _infoItem('Expiry', '$expiryDate'),
                      ),
                    ],
                  ),
                  if (status.toLowerCase() == 'rejected' &&
                      rejectionReason != null) ...[
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
                              'Rejected: $rejectionReason',
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
                        final url = doc['url'] ?? doc['fileUrl'];
                        if (url != null) {
                          Get.snackbar('Document', 'Opening document...',
                              snackPosition: SnackPosition.BOTTOM);
                        }
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
                        arguments: {'type': docType}),
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: Text(isUploaded ? 'Re-Upload' : 'Upload'),
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
