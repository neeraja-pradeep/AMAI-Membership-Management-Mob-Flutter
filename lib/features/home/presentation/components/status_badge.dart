import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Reusable status badge widget
/// Used for membership status, insurance status, etc.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.isActive,
    super.key,
    this.isExpired = false,
    this.isExpiringSoon = false,
  });

  /// Badge label text
  final String label;

  /// Whether the status is active
  final bool isActive;

  /// Whether the status is expired
  final bool isExpired;

  /// Whether expiring soon
  final bool isExpiringSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: _textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (isExpired) return AppColors.expiredBadge;
    if (isExpiringSoon) return AppColors.expiringSoonBadge;
    if (isActive) return AppColors.activeBadge;
    return AppColors.inactiveBadge;
  }

  Color get _textColor {
    if (isExpired) return AppColors.expiredBadgeText;
    if (isExpiringSoon) return AppColors.expiringSoonBadgeText;
    if (isActive) return AppColors.activeBadgeText;
    return AppColors.inactiveBadgeText;
  }
}

/// Factory constructor for creating status badge from membership state
class MembershipStatusBadge extends StatelessWidget {
  const MembershipStatusBadge({
    required this.isActive,
    required this.isExpired,
    required this.isExpiringSoon,
    super.key,
  });

  final bool isActive;
  final bool isExpired;
  final bool isExpiringSoon;

  @override
  Widget build(BuildContext context) {
    String label;

    if (!isActive) {
      label = 'Inactive';
    } else if (isExpired) {
      label = 'Expired';
    } else if (isExpiringSoon) {
      label = 'Expiring Soon';
    } else {
      label = 'Active';
    }

    return StatusBadge(
      label: label,
      isActive: isActive && !isExpired,
      isExpired: isExpired,
      isExpiringSoon: isExpiringSoon && !isExpired,
    );
  }
}
