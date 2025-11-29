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

  /// Builds the section header with title and "View All" button
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontally scrollable actions list
  Widget _buildActionsList() {
    final actions = _getQuickActions();

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: actions.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final action = actions[index];
          return QuickActionItem(
            icon: action.icon,
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
    return [
      _QuickActionData(
        icon: Icons.card_membership_outlined,
        label: 'Membership',
        onTap: onMembershipTap,
        iconColor: AppColors.primary,
        backgroundColor: AppColors.primary.withOpacity(0.1),
      ),
      _QuickActionData(
        icon: Icons.health_and_safety_outlined,
        label: 'Aswas Plus',
        onTap: onAswasePlusTap,
        iconColor: AppColors.success,
        backgroundColor: AppColors.success.withOpacity(0.1),
      ),
      _QuickActionData(
        icon: Icons.school_outlined,
        label: 'Academy',
        onTap: onAcademyTap,
        iconColor: AppColors.secondary,
        backgroundColor: AppColors.secondary.withOpacity(0.1),
      ),
      _QuickActionData(
        icon: Icons.contacts_outlined,
        label: 'Contacts',
        onTap: onContactsTap,
        iconColor: AppColors.info,
        backgroundColor: AppColors.info.withOpacity(0.1),
      ),
    ];
  }
}

/// Internal data class for quick action items
class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
}
