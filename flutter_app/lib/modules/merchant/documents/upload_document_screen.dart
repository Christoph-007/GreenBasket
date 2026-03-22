import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbasket_app/config/theme.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  // TODO: get document type from Get.arguments
  String get _documentType =>
      (Get.arguments as Map<String, dynamic>?)?['type'] as String? ??
      'Document';

  bool _fileSelected = false;
  String _selectedFileName = '';
  bool _isImage = false;

  final _docNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expiryDate;

  @override
  void dispose() {
    _docNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select expiry date';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _selectFile() {
    // TODO: open file picker (image/PDF)
    setState(() {
      _fileSelected = true;
      _isImage = true;
      _selectedFileName =
          '${_documentType.toLowerCase().replaceAll(' ', '_')}_doc.pdf';
    });
  }

  void _uploadDocument() {
    if (!_fileSelected) {
      Get.snackbar(
        'No File',
        'Please select a document to upload',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // TODO: call API to upload document
    Get.back();
    Get.snackbar(
      'Document Uploaded',
      'Your document is under review',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Document'),
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
            // Document type header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_outlined,
                      color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uploading',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary)),
                      Text(_documentType,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Upload area
            Text('Document File', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _selectFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: _fileSelected
                      ? AppColors.primaryContainer
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _fileSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _fileSelected
                          ? (_isImage
                              ? Icons.image_outlined
                              : Icons.picture_as_pdf_outlined)
                          : Icons.cloud_upload_outlined,
                      size: 52,
                      color: _fileSelected
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _fileSelected
                          ? _selectedFileName
                          : 'Tap to upload',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _fileSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _fileSelected
                          ? 'Tap to change file'
                          : 'Supported: JPG, PNG, PDF (Max 5MB)',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (_fileSelected) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text('File ready to upload',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.success)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Document details form
            Text('Document Details', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _docNumberController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: _getDocNumberLabel(),
                hintText: _getDocNumberHint(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Expiry date
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _expiryDate != null
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: _expiryDate != null
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expiry Date',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textHint)),
                          Text(
                            _formatDate(_expiryDate),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _expiryDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional information...',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Info banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border:
                    Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your document will be reviewed within 2-3 business days. You will be notified once the verification is complete.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploadDocument,
              icon: const Icon(Icons.upload_outlined),
              label: const Text('Upload Document'),
            ),
          ),
        ),
      ),
    );
  }

  String _getDocNumberLabel() {
    if (_documentType.contains('FSSAI')) return 'FSSAI License Number';
    if (_documentType.contains('GST')) return 'GSTIN Number';
    if (_documentType.contains('Trade')) return 'Trade License Number';
    return 'Document Number';
  }

  String _getDocNumberHint() {
    if (_documentType.contains('FSSAI')) return 'e.g. 12345678901234';
    if (_documentType.contains('GST')) return 'e.g. 29AAAAA0000A1Z5';
    if (_documentType.contains('Trade')) return 'e.g. TL/2024/001234';
    return 'Enter document number';
  }
}
