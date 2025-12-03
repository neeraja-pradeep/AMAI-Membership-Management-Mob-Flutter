import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/features/home/infrastructure/data_sources/local/home_local_ds.dart';
import 'package:myapp/features/home/presentation/screens/home_screen.dart';
import 'package:myapp/features/membership/infrastructure/data_sources/local/membership_local_ds.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes before app runs (prevents race conditions)
  await Hive.openBox(HomeBoxKeys.boxName);
  await Hive.openBox(MembershipBoxKeys.boxName);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Figma design size as per documentation
      designSize: const Size(390, 835),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'AMAI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
              error: AppColors.error,
            ),
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            useMaterial3: true,
          ),
          home: child,
        );
      },
      child: const HomeScreen(),
    );
  }
}
