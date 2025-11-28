import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/features/auth/application/states/registration_state.dart';
// NOTE: file_picker package required - add to pubspec.yaml
// import 'package:file_picker/file_picker.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../domain/entities/registration/document_upload.dart';
import '../../components/step_progress_indicator.dart';

/// Document Upload Screen (Step 4)
///
/// Allows users to upload required documents:
/// - Medical Council Certificate (required)
/// - Qualification Certificate (required)
/// - Identity Proof (required)
/// - Profile Photo (required)
/// - Additional Certificates (optional)
///
/// CRITICAL REQUIREMENTS:
/// - File size validation (max 5MB per file)
/// - File type validation (PDF, JPG, PNG)
/// - One-time upload (files deleted after submission)
/// - All required documents must be uploaded
class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final Map<DocumentType, File?> _uploadedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
  }

  /// Load existing documents from registration state
  void _loadExistingDocuments() {
    final state = ref.read(registrationProvider);

    if (state is RegistrationStateInProgress) {
      final documentUploads = state.registration.documentUploads;

      if (documentUploads != null) {
        for (final doc in documentUploads.documents) {
          _uploadedFiles[doc.type] = File(doc.localFilePath);
        }
      }
    }
  }

  /// Pick file for document type
  Future<void> _pickFile(DocumentType type) async {
    // TODO: Uncomment when file_picker is added to pubspec.yaml
    /*
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Validate file size (max 5MB)
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _uploadedFiles[type] = file;
        });

        // Save to registration state
        _saveDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */

    // MOCK: For now, show message that file picker is not implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File picker for ${type.displayName} (TODO: Implement)'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Remove uploaded file
  void _removeFile(DocumentType type) {
    setState(() {
      _uploadedFiles.remove(type);
    });
    _saveDocuments();
  }

  /// Save documents to registration state
  void _saveDocuments() {
    // TODO: Implement document saving to registration state
    // This would create DocumentUpload entities and save to DocumentUploads
  }

  /// Check if all required documents are uploaded
  bool _areRequiredDocumentsUploaded() {
    final requiredTypes = DocumentType.values.where((type) => type.isRequired);

    for (final type in requiredTypes) {
      if (!_uploadedFiles.containsKey(type) || _uploadedFiles[type] == null) {
        return false;
      }
    }

    return true;
  }

  /// Handle next button press
  Future<void> _handleNext() async {
    if (!_areRequiredDocumentsUploaded()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save documents
    _saveDocuments();

    // Auto-save to Hive
    await ref.read(registrationProvider.notifier).autoSaveProgress();

    // Navigate to payment screen
    if (mounted) {
      Navigator.pushNamed(context, AppRouter.registrationPayment);
    }
  }

  /// Handle back button press
  void _handleBack() {
    _saveDocuments();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allRequiredUploaded = _areRequiredDocumentsUploaded();

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              const StepProgressIndicator(
                currentStep: 4,
                totalSteps: 5,
                stepTitle: 'Document Uploads',
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        'Upload Documents',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Please upload the required documents (max 5MB each)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Document upload cards
                      ...DocumentType.values.map((type) {
                        final file = _uploadedFiles[type];
                        final isUploaded = file != null;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _DocumentCard(
                            documentType: type,
                            file: file,
                            isUploaded: isUploaded,
                            onUpload: () => _pickFile(type),
                            onRemove: () => _removeFile(type),
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 16.h),

                      // Requirements note
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Accepted formats: PDF, JPG, PNG\nMax file size: 5MB',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Next button
                      SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: allRequiredUploaded ? _handleNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: allRequiredUploaded
                                      ? Colors.white
                                      : Colors.grey[500],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_forward,
                                size: 20.sp,
                                color: allRequiredUploaded
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document upload card widget
class _DocumentCard extends StatelessWidget {
  final DocumentType documentType;
  final File? file;
  final bool isUploaded;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _DocumentCard({
    required this.documentType,
    required this.file,
    required this.isUploaded,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isUploaded ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isUploaded ? Colors.green[300]! : Colors.grey[300]!,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document type header
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color: isUploaded ? Colors.green[700] : Colors.grey[600],
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentType.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (documentType.isRequired)
                      Text(
                        'Required',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (isUploaded && file != null) ...[
            SizedBox(height: 12.h),
            // File info
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: Colors.grey[600],
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      file!.path.split('/').last,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[600],
                      size: 20.sp,
                    ),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
          ],

          if (!isUploaded) ...[
            SizedBox(height: 12.h),
            // Upload button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onUpload,
                icon: Icon(Icons.cloud_upload, size: 18.sp),
                label: Text('Choose File', style: TextStyle(fontSize: 14.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                  side: const BorderSide(color: Color(0xFF1976D2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
