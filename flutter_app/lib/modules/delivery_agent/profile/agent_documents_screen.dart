import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';

// TODO: Replace mock data with API: GET /agent/documents
// TODO: Upload via POST /agent/documents/:type with multipart/form-data

enum DocStatus { verified, pendingReview, rejected, notUploaded }

class AgentDocumentsScreen extends StatefulWidget {
  const AgentDocumentsScreen({super.key});

  @override
  State<AgentDocumentsScreen> createState() => _AgentDocumentsScreenState();
}

class _AgentDocumentsScreenState extends State<AgentDocumentsScreen> {
  // Mock document statuses — replace with API data
  final List<Map<String, dynamic>> _documents = [
    {
      'title': 'Driving License',
      'subtitle': 'Valid driving license (front & back)',
      'icon': Icons.badge_outlined,
      'status': DocStatus.verified,
      'lastUpdated': 'Jan 15, 2026',
    },
    {
      'title': 'Aadhaar Card',
      'subtitle': 'Government-issued identity proof',
      'icon': Icons.credit_card_outlined,
      'status': DocStatus.pendingReview,
      'lastUpdated': 'Mar 10, 2026',
    },
    {
      'title': 'Vehicle Registration Certificate',
      'subtitle': 'RC book of your delivery vehicle',
      'icon': Icons.description_outlined,
      'status': DocStatus.verified,
      'lastUpdated': 'Jan 15, 2026',
    },
    {
      'title': 'Vehicle Insurance',
      'subtitle': 'Valid vehicle insurance policy',
      'icon': Icons.policy_outlined,
      'status': DocStatus.rejected,
      'lastUpdated': 'Feb 28, 2026',
    },
  ];

  DocStatus get _overallStatus {
    if (_documents.any((d) => d['status'] == DocStatus.rejected)) {
      return DocStatus.rejected;
    }
    if (_documents.any((d) => d['status'] == DocStatus.notUploaded)) {
      return DocStatus.notUploaded;
    }
    if (_documents.any((d) => d['status'] == DocStatus.pendingReview)) {
      return DocStatus.pendingReview;
    }
    return DocStatus.verified;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Documents'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildVerificationBanner(),
            const SizedBox(height: AppSpacing.md),
            ..._documents.map((doc) => _buildDocumentCard(doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    final status = _overallStatus;
    final (color, icon, message) = switch (status) {
      DocStatus.verified => (
          AppColors.success,
          Icons.verified_outlined,
          'All documents verified. You can accept deliveries.'
        ),
      DocStatus.pendingReview => (
          AppColors.warning,
          Icons.hourglass_empty_outlined,
          'Some documents are under review. We\'ll notify you soon.'
        ),
      DocStatus.rejected => (
          AppColors.error,
          Icons.error_outline,
          'Some documents were rejected. Please re-upload.'
        ),
      DocStatus.notUploaded => (
          AppColors.textSecondary,
          Icons.upload_file_outlined,
          'Please upload all required documents to start deliveries.'
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final status = doc['status'] as DocStatus;
    final (statusLabel, statusColor) = _statusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(doc['icon'] as IconData,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc['title'] as String,
                        style: AppTextStyles.titleMedium),
                    Text(
                      doc['subtitle'] as String,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              _statusBadge(statusLabel, statusColor),
            ],
          ),
          if (doc['lastUpdated'] != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.update_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Last updated: ${doc['lastUpdated']}',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ],
          if (status == DocStatus.rejected)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Reason: Document is blurry or expired. Please re-upload.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (status == DocStatus.verified)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUploadDialog(doc['title'] as String),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Re-upload'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(doc['title'] as String),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: Text(
                      status == DocStatus.rejected ? 'Re-upload' : 'Upload',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == DocStatus.rejected
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _statusInfo(DocStatus status) {
    return switch (status) {
      DocStatus.verified => ('Verified', AppColors.success),
      DocStatus.pendingReview => ('Pending Review', AppColors.warning),
      DocStatus.rejected => ('Rejected', AppColors.error),
      DocStatus.notUploaded => ('Not Uploaded', AppColors.textSecondary),
    };
  }

  void _showUploadDialog(String docTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Upload $docTitle', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose how you want to upload your document',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _uploadOption(
                    Icons.camera_alt_outlined,
                    'Camera',
                    () {
                      // TODO: Open camera
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _uploadOption(
                    Icons.photo_library_outlined,
                    'Gallery',
                    () {
                      // TODO: Open image picker
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _uploadOption(
                    Icons.insert_drive_file_outlined,
                    'Files',
                    () {
                      // TODO: Open file picker
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}
