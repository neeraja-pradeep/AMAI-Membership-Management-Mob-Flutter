import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniSuccessCard extends StatefulWidget {
  final VoidCallback onBackHome;

  const MiniSuccessCard({super.key, required this.onBackHome});

  @override
  State<MiniSuccessCard> createState() => _MiniSuccessCardState();
}

class _MiniSuccessCardState extends State<MiniSuccessCard> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              /// Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 60.sp,
                        color: Colors.green,
                      ),

                      SizedBox(height: 12.h),

                      Text(
                        "Successfully Registered 🎉",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Text(
                        "Thank you for registering!\nYour application has been successfully submitted and is now pending administrative review.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4,
                          color: Colors.grey[700],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      TextButton(
                        onPressed: widget.onBackHome,
                        child: Text(
                          "Back to Home",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Confetti Animation
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 25,
            emissionFrequency: 0.05,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Colors.blue,
              Colors.orange,
              Colors.green,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}
