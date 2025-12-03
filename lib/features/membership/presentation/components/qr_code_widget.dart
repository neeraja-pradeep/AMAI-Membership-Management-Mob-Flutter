import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR Code Widget for displaying membership QR codes
/// Uses qr_flutter package to generate QR from string data
class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    required this.data,
    this.size,
    super.key,
  });

  /// The data string to encode in the QR code
  final String data;

  /// Size of the QR code (width and height)
  /// Defaults to 180.w if not specified
  final double? size;

  @override
  Widget build(BuildContext context) {
    final qrSize = size ?? 180.w;

    // Handle empty or invalid data gracefully
    if (data.isEmpty) {
      return _buildEmptyState(qrSize);
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: qrSize,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
        errorStateBuilder: (context, error) {
          return _buildErrorState(qrSize);
        },
      ),
    );
  }

  /// Builds the empty state when no data is provided
  Widget _buildEmptyState(double size) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.grey300,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 48.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 8.h),
            Text(
              'QR Code unavailable',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state when QR generation fails
  Widget _buildErrorState(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 8.h),
            Text(
              'Failed to generate QR',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
