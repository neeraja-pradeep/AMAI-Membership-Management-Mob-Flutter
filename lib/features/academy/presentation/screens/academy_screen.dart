import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/app/theme/typography.dart';

/// Academy Screen - displays information about AMAI Academy
class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  static const String _academyDescription = '''AMAI is an organization that aims at functioning for Ayurveda doctors to strengthen existing knowledge and practice and sharpen the minds of the new generation of Ayurveda doctors that is capable of catering to the emerging demands of the modern society. In the past four decades, the mission of the organization has branched out to various areas of Ayurveda health care that benefits both the service provider as well as the general population.

In order to meet the growing demands of professionalism and expertise in the field of Ayurveda, AMAI Academy was launched to train ayurveda graduates to crack the competitive AIAPGET examination. With the possibility of pursuing post -graduation in various esteemed universities across the country, Amai academy intends to offer value added coaching classes covering all areas of the syllabus by experts from respective subjects. Since COVID 19 pandemic took its toll on us, learning has widely become online. AMA academy offers online classes with complete notes and take aways for cracking the exam.

Success is the end result of focussed team work and doesn't happen overnight. With this vision, AMA offers a well charted year plan that will be headed by individual mentors for each aspirant ensuring that pit falls are minimum and the road to success is wide open. Competition always takes a toll on the body and mind. In order to ensure that our aspirants don't fall prey to the burden of stress, we provide a completely harmonious environment for them to thrive.

One year into this journey and the academy is happily overwhelmed with queries regarding coaching for various other examinations as well. Positive feedback from our existing aspirants has added to our value. With ayurveda doctors seeking collaboration with various other branches like administrative services and overseas jobs, the academy intends to extend hands to prepare the bright and young minds for similar opportunities in India and abroad''';

  static const String _contactNumber = '+91 9876534210';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Academy',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description text
            Text(
              _academyDescription,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            // Contact Us Card
            _buildContactCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                _contactNumber,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
