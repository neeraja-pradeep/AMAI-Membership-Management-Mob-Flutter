import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';
import 'package:myapp/features/home/presentation/components/quick_action_item.dart';

/// Quick actions section for the homescreen
/// Displays horizontally scrollable action items
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    this.onViewAll,
    this.onMembershipTap,
    this.onAswasePlusTap,
    this.onAcademyTap,
    this.onContactsTap,
    this.membershipType,
  });

  /// Callback when "View All" is tapped
  final VoidCallback? onViewAll;

  /// Callback when Membership action is tapped
  final VoidCallback? onMembershipTap;

  /// Callback when Aswas Plus action is tapped
  final VoidCallback? onAswasePlusTap;

  /// Callback when Academy action is tapped
  final VoidCallback? onAcademyTap;

  /// Callback when Contacts action is tapped
  final VoidCallback? onContactsTap;

  /// Membership type to conditionally show/hide ASWAS Plus
  final String? membershipType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildActionsList(),
      ],
    );
  }

  /// Builds the section header with title
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'Quick Actions',
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  /// Builds the horizontally scrollable actions list
  Widget _buildActionsList() {
    final actions = _getQuickActions();

    return SizedBox(
      height: 125.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: actions.length,
        separatorBuilder: (context, index) => SizedBox(width: 32.w),
        itemBuilder: (context, index) {
          final action = actions[index];
          return QuickActionItem(
            svgAsset: action.svgAsset,
            label: action.label,
            onTap: action.onTap ?? () {},
            iconColor: action.iconColor,
            backgroundColor: action.backgroundColor,
          );
        },
      ),
    );
  }

  /// Returns the list of quick action items
  List<_QuickActionData> _getQuickActions() {
    // Check if ASWAS Plus should be hidden for student or house_surgeon
    final hideAswasPlus =
        membershipType == 'student' || membershipType == 'house_surgeon';

    final actions = <_QuickActionData>[
      _QuickActionData(
        svgAsset: 'assets/svg/membership.svg',
        label: 'Membership',
        onTap: onMembershipTap,
        iconColor: AppColors.white,
        backgroundColor: AppColors.newPrimaryLight,
      ),
    ];

    // Only add ASWAS Plus if not student or house_surgeon
    if (!hideAswasPlus) {
      actions.add(
        _QuickActionData(
          svgAsset: 'assets/svg/aswas.svg',
          label: 'Aswas Plus',
          onTap: onAswasePlusTap,
          iconColor: AppColors.white,
          backgroundColor: AppColors.newPrimaryLight,
        ),
      );
    }

    actions.addAll([
      _QuickActionData(
        svgAsset: 'assets/svg/academy.svg',
        label: 'Academy',
        onTap: onAcademyTap,
        iconColor: AppColors.white,
        backgroundColor: AppColors.newPrimaryLight,
      ),
      const _QuickActionData(
        svgAsset: 'assets/svg/ecommerce.svg',
        label: 'Ecommerce',
        onTap: null,
        iconColor: AppColors.white,
        backgroundColor: AppColors.newPrimaryLight,
      ),
      _QuickActionData(
        svgAsset: 'assets/svg/contacts.svg',
        label: 'Contacts',
        onTap: onContactsTap,
        iconColor: AppColors.white,
        backgroundColor: AppColors.newPrimaryLight,
      ),
    ]);

    return actions;
  }
}

/// Internal data class for quick action items
class _QuickActionData {
  const _QuickActionData({
    required this.svgAsset,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  final String svgAsset;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
}
