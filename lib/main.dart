import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/app/router/app_router.dart';
import 'package:myapp/core/network/api_client_provider.dart';
import 'package:myapp/features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize API client with cookie persistence
  await apiClientInstance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Adjust for your UI
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // 👇 this is required so navigation works
          onGenerateRoute: AppRouter.generateRoute,

          // 👇 starting screen - Splash screen handles session check
          home: const SplashScreen(),
        );
      },
    );
  }
}
