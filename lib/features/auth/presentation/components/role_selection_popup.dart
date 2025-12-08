import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import '../../domain/entities/user_role.dart';

/// Role selection popup
///
/// Allows user to select their membership role:
/// - Practitioner
/// - House Surgeon
/// - Student
class RoleSelectionPopup extends StatefulWidget {
  const RoleSelectionPopup({super.key});

  @override
  State<RoleSelectionPopup> createState() => _RoleSelectionPopupState();
}

class _RoleSelectionPopupState extends State<RoleSelectionPopup> {
  UserRole? _selectedRole;

  void _handleContinue() {
    if (_selectedRole != null) {
      Navigator.pop(context, _selectedRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // Title
            Text(
              'Register as',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 24.h),

            // Role options
            _RoleOption(
              role: UserRole.practitioner,
              isSelected: _selectedRole == UserRole.practitioner,
              onTap: () {
                setState(() {
                  _selectedRole = UserRole.practitioner;
                });
              },
            ),

            SizedBox(height: 7.h),

            _RoleOption(
              role: UserRole.houseSurgeon,
              isSelected: _selectedRole == UserRole.houseSurgeon,
              onTap: () {
                setState(() {
                  _selectedRole = UserRole.houseSurgeon;
                });
              },
            ),

            SizedBox(height: 7.h),

            _RoleOption(
              role: UserRole.student,
              isSelected: _selectedRole == UserRole.student,
              onTap: () {
                setState(() {
                  _selectedRole = UserRole.student;
                });
              },
            ),

            SizedBox(height: 24.h),

            // Continue button
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _selectedRole != null ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: _selectedRole != null
                        ? Colors.white
                        : Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Role option tile
class _RoleOption extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.brown : Colors.grey[300]!,
            width: isSelected ? 1 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.brown : Colors.grey[400]!,
                  width: 1,
                ),
                color: isSelected ? AppColors.brown : Colors.white,
              ),
            ),

            SizedBox(width: 12.w),

            // Role name
            Expanded(
              child: Text(
                role.displayName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
                  color: isSelected ? AppColors.black : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
