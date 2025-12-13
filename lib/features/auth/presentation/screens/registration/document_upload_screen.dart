import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/auth/domain/entities/registration/registration_error.dart';
import 'package:myapp/features/navigation/presentation/screens/main_navigation_screen.dart';

import '../../../../../app/router/app_router.dart';
import '../../../application/notifiers/registration_state_notifier.dart';
import '../../../application/states/registration_state.dart';
import '../../../domain/entities/registration/document_upload.dart';
import '../../components/registration_step_indicator.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

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
  bool _registrationComplete = false;

  /// 👇 Pulled from Riverpod instead of Navigator arguments
  int? _applicationId;
  String _role = 'practitioner'; // "practitioner" | "house_surgeon" | "student"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });
  }

  void _initFromProvider() {
    final state = ref.read(registrationProvider);

    // If RegistrationStateResumePrompt somehow still exists here,
    // it means the user bypassed the resume dialog. Start fresh instead.
    if (state is RegistrationStateResumePrompt) {
      ref.read(registrationProvider.notifier).startFreshRegistration();
      return;
    }

    if (state is! RegistrationStateInProgress) {
      _showError("Registration not in progress.");
      return;
    }

    final reg = state.registration;

    _role = reg.personalDetails?.membershipType ?? 'practitioner';
    _applicationId = reg.applicationId;

    // Restore previously saved files (if any)
    final docs = reg.documentUploads?.documents ?? [];
    for (var doc in docs) {
      if (doc.type == DocumentType.profilePhoto) {
        profilePhoto = File(doc.localFilePath);
      } else if (doc.type == DocumentType.medicalCouncilCertificate) {
        certificate = File(doc.localFilePath);
      }
    }

    setState(() {});
  }

  /// 🔥 Pick file TYPE based on role (from provider)
  Future<void> _pickFile({required bool isProfile}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: isProfile
          ? ['jpg', 'jpeg', 'png']
          : _role == "student"
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

    if (_applicationId == null) {
      _showError("Missing application ID. Please restart registration.");
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
            application: _applicationId!, // ✅ from provider
            documentFile: file,
            documentType: extension,
          );

      if (response == null || response["document_url"] == null) {
        _showError("Upload failed — backend did not accept document.");
        return;
      }

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
            "${isProfile ? "Profile Photo" : _certificateLabel()} uploaded successfully!",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
      );
    } on RegistrationError catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Upload failed. Please try again.");
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

  /// 🔥 Label based on role from provider
  String _certificateLabel() {
    if (_role == "house_surgeon") {
      return "Provisional Registration Certificate";
    } else if (_role == "student") {
      return "College ID Card";
    }
    return "Medical Council Certificate"; // default for practitioners
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

    // Students don't need to pay - show success directly
    if (_role == "student") {
      setState(() => _registrationComplete = true);
      return;
    }

    Navigator.pushNamed(context, AppRouter.registrationPayment);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Color(0xFF60212E), content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final canProceed =
        (profilePhoto != null && certificate != null && acceptedTerms);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Register Here",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RegistrationStepIndicator(currentStep: 4),

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

                    SizedBox(height: 24.h),

                    // Profile Picture Section
                    _buildUploadSection(
                      title: "Profile Picture",
                      file: profilePhoto,
                      onPick: isUploading ? null : () => _pickFile(isProfile: true),
                      onRemove: isUploading ? null : () => _removeFile(true),
                      uploadText: "Click to upload profile picture",
                      svgIcon: 'assets/svg/camera.svg',
                    ),

                    SizedBox(height: 16.h),

                    // Certificate Section
                    _buildUploadSection(
                      title: _certificateLabel(),
                      file: certificate,
                      onPick: isUploading ? null : () => _pickFile(isProfile: false),
                      onRemove: isUploading ? null : () => _removeFile(false),
                      uploadText: "Click to upload certificate",
                      svgIcon: 'assets/svg/file.svg',
                    ),

                    SizedBox(height: 24.h),

                    // Terms & Conditions checkbox
                    _buildTermsCheckbox(),

                    SizedBox(height: 32.h),

                    // Back and Next buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.brown),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                              ),
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  color: AppColors.brown,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: SizedBox(
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: canProceed ? _next : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brown,
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                              ),
                              child: Text(
                                "Next",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),

              // Student Registration Success Overlay
              if (_registrationComplete)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      width: 300.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 60.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Registration Successful!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Thank you for registering!\nYour application has been successfully submitted and is now pending administrative review.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp, height: 1.4),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MainNavigationScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                              ),
                              child: Text(
                                "Back to Home",
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required File? file,
    required VoidCallback? onPick,
    required VoidCallback? onRemove,
    required String uploadText,
    required String svgIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        file == null
            ? InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(12.r),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: Colors.grey[400]!,
                    strokeWidth: 1.5,
                    dashWidth: 6,
                    dashSpace: 4,
                    borderRadius: 12.r,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          svgIcon,
                          height: 34.h,
                          width: 34.w,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          uploadText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 24.sp,
                      color: AppColors.brown,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        file.path.split('/').last,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: onPick,
                      child: Text(
                        "Replace",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onRemove,
                      child: Text(
                        "Remove",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: isUploading ? null : () => setState(() => acceptedTerms = !acceptedTerms),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: acceptedTerms ? AppColors.brown : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: acceptedTerms ? AppColors.brown : Colors.grey[400]!,
                width: 1.5,
              ),
            ),
            child: acceptedTerms
                ? Icon(
                    Icons.check,
                    size: 14.sp,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: "I agree to the "),
                  TextSpan(
                    text: "Terms & Condition",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.brown,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = dashWidth;
        if (distance + length > metric.length) {
          dashPath.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
        } else {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
