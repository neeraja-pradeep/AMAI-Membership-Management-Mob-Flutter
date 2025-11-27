import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Select Your Role',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1976D2),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Choose your membership type to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
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

            SizedBox(height: 12.h),

            _RoleOption(
              role: UserRole.houseSurgeon,
              isSelected: _selectedRole == UserRole.houseSurgeon,
              onTap: () {
                setState(() {
                  _selectedRole = UserRole.houseSurgeon;
                });
              },
            ),

            SizedBox(height: 12.h),

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
              height: 50.h,
              child: ElevatedButton(
                onPressed: _selectedRole != null ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _selectedRole != null ? Colors.white : Colors.grey[500],
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
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
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1976D2) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.white,
                    )
                  : null,
            ),

            SizedBox(width: 12.w),

            // Role name
            Expanded(
              child: Text(
                role.displayName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1976D2) : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
