import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../application/states/registration_state.dart';
import '../../../domain/entities/registration/document_upload.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final int applicationId;

  const DocumentUploadScreen({super.key, required this.applicationId});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  File? profilePhoto;
  File? certificate;
  bool acceptedTerms = false;
  bool isUploading = false;
  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _restoreSavedFiles();
  }

  void _restoreSavedFiles() {
    final state = ref.read(registrationProvider);
    if (state is! RegistrationStateInProgress) return;

    final docs = state.registration.documentUploads?.documents ?? [];

    for (var doc in docs) {
      if (doc.type == DocumentType.profilePhoto) {
        profilePhoto = File(doc.localFilePath);
      } else if (doc.type == DocumentType.medicalCouncilCertificate) {
        certificate = File(doc.localFilePath);
      }
    }

    setState(() {});
  }

  Future<void> _pickFile({required bool isProfile}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: isProfile
          ? ['jpg', 'jpeg', 'png']
          : ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null) {
      return;
    }

    final file = File(result.files.single.path!);

    final sizeMB = (await file.length()) / (1024 * 1024);

    if (sizeMB > 5) {
      _showError("File must be under 5MB.");
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    final extension = ".${file.path.split('.').last.toLowerCase()}";

    try {
      final state = ref.read(registrationProvider);

      if (state is! RegistrationStateInProgress) {
        _showError("Registration not in progress.");
        return;
      }

      final response = await ref
          .read(registrationProvider.notifier)
          .submitDocuments(
            application: widget.applicationId,
            documentFile: file,
            documentType: extension,
          );

      if (response == null || response["document_url"] == null) {
        _showError("Upload failed — backend did not accept document.");
        return;
      }

      // Save state only after success
      setState(() {
        if (isProfile) {
          profilePhoto = file;
        } else {
          certificate = file;
        }
      });

      _saveToState();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${isProfile ? "Profile Photo" : "Certificate"} uploaded successfully!",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError("Upload failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
          uploadProgress = 0;
        });
      }
    }
  }

  void _removeFile(bool isProfile) {
    if (isUploading) return;

    setState(() {
      if (isProfile) {
        profilePhoto = null;
      } else {
        certificate = null;
      }
    });

    _saveToState();
  }

  void _saveToState() {
    final docs = <DocumentUpload>[];

    if (profilePhoto != null) {
      docs.add(
        DocumentUpload(
          type: DocumentType.profilePhoto,
          localFilePath: profilePhoto!.path,
          fileName: profilePhoto!.path.split('/').last,
          fileSizeBytes: profilePhoto!.lengthSync(),
          uploadedAt: DateTime.now(),
        ),
      );
    }

    if (certificate != null) {
      docs.add(
        DocumentUpload(
          type: DocumentType.medicalCouncilCertificate,
          localFilePath: certificate!.path,
          fileName: certificate!.path.split('/').last,
          fileSizeBytes: certificate!.lengthSync(),
          uploadedAt: DateTime.now(),
        ),
      );
    }

    ref
        .read(registrationProvider.notifier)
        .updateDocumentUploads(DocumentUploads(documents: docs));
  }

  Future<void> _next() async {
    if (profilePhoto == null || certificate == null) {
      _showError("Ensure both files are successfully uploaded.");
      return;
    }

    if (!acceptedTerms) {
      _showError("You must agree to the Terms & Conditions.");
      return;
    }

    Navigator.pushNamed(context, AppRouter.registrationPayment);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final canProceed =
        (profilePhoto != null && certificate != null && acceptedTerms);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Register Here",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            Center(
              child: Text(
                "Step 4 of 4",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),

            if (isUploading)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: LinearProgressIndicator(
                  value: uploadProgress == 0 ? null : uploadProgress,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.brown,
                  minHeight: 4,
                ),
              ),

            SizedBox(height: 30.h),

            _label("Profile Photo"),
            _uploadTile(
              file: profilePhoto,
              onPick: isUploading ? null : () => _pickFile(isProfile: true),
              onRemove: isUploading ? null : () => _removeFile(true),
            ),

            SizedBox(height: 25.h),

            _label("Medical Council Certificate"),
            _uploadTile(
              file: certificate,
              onPick: isUploading ? null : () => _pickFile(isProfile: false),
              onRemove: isUploading ? null : () => _removeFile(false),
            ),

            SizedBox(height: 30.h),

            Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  onChanged: isUploading
                      ? null
                      : (v) => setState(() => acceptedTerms = v!),
                  activeColor: AppColors.brown,
                ),
                Expanded(
                  child: Text(
                    "I agree to the Terms & Conditions",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: canProceed ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed
                      ? AppColors.brown
                      : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _uploadTile({
    required File? file,
    required VoidCallback? onPick,
    required VoidCallback? onRemove,
  }) {
    return InkWell(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey),
        ),
        child: file == null
            ? Column(
                children: [
                  Icon(Icons.upload_file, size: 40.sp, color: Colors.grey),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap to Upload",
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(file.path.split('/').last)),
                  TextButton(onPressed: onPick, child: const Text("Replace")),
                  TextButton(
                    onPressed: onRemove,
                    child: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
