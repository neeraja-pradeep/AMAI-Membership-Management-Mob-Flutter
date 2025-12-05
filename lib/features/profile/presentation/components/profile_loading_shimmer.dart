import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';

/// Loading shimmer for profile screen
class ProfileLoadingShimmer extends StatefulWidget {
  const ProfileLoadingShimmer({super.key});

  @override
  State<ProfileLoadingShimmer> createState() => _ProfileLoadingShimmerState();
}

class _ProfileLoadingShimmerState extends State<ProfileLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 24.h),
              // Avatar shimmer
              _buildCircleShimmer(100.w),
              SizedBox(height: 16.h),
              // Name shimmer
              _buildRectShimmer(150.w, 20.h),
              SizedBox(height: 8.h),
              // Email shimmer
              _buildRectShimmer(200.w, 14.h),
              SizedBox(height: 24.h),
              // Personal info card shimmer
              _buildCardShimmer(),
              SizedBox(height: 16.h),
              // Edit options card shimmer
              _buildCardShimmer(height: 200.h),
              SizedBox(height: 16.h),
              // Support section shimmer
              _buildCardShimmer(height: 150.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleShimmer(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey300.withOpacity(_animation.value),
      ),
    );
  }

  Widget _buildRectShimmer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: AppColors.grey300.withOpacity(_animation.value),
      ),
    );
  }

  Widget _buildCardShimmer({double? height}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      height: height ?? 180.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRectShimmer(120.w, 16.h),
          SizedBox(height: 16.h),
          _buildRectShimmer(double.infinity, 12.h),
          SizedBox(height: 12.h),
          _buildRectShimmer(double.infinity, 12.h),
          SizedBox(height: 12.h),
          _buildRectShimmer(200.w, 12.h),
        ],
      ),
    );
  }
}
