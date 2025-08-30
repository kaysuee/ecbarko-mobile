import 'package:EcBarko/screens/about_screen.dart';
import 'package:EcBarko/screens/forgotpassword_screen.dart';
import 'package:EcBarko/screens/welcome_screen.dart';
import 'package:EcBarko/screens/responsive_example_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:EcBarko/services/notification_scheduler.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/screens/home_screen.dart';
import '/screens/dashboard_screen.dart';
import '/screens/splash_screen.dart';
import 'package:EcBarko/screens/login_screen.dart';
import 'package:EcBarko/screens/register_screen.dart';
import 'package:EcBarko/screens/booking_screen.dart';
import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/rates_screen.dart';
import 'package:EcBarko/screens/FAQs_screen.dart';
import 'package:EcBarko/screens/otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for Philippine time (Asia/Manila)
  await initializeDateFormatting('en_US', null);

  final prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final token = prefs.getString('token');

  // Validate token if it exists
  if (token != null && JwtDecoder.isExpired(token)) {
    await prefs.clear();
    isLoggedIn = false;
  }

  // Start notification scheduler for booking reminders
  if (isLoggedIn) {
    NotificationScheduler.startScheduler();
  }

  runApp(EcBarkoMobile(isLoggedIn: isLoggedIn));
}

class EcBarkoMobile extends StatelessWidget {
  final bool isLoggedIn;

  const EcBarkoMobile({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
          375, 812), // iPhone X design size for better mobile-first approach
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EcBarko Mobile',
          initialRoute: '/splash',
          theme: ThemeData(
            // Responsive theme configuration
            textTheme: TextTheme(
              displayLarge: TextStyle(fontSize: 32.sp),
              displayMedium: TextStyle(fontSize: 28.sp),
              displaySmall: TextStyle(fontSize: 24.sp),
              headlineLarge: TextStyle(fontSize: 22.sp),
              headlineMedium: TextStyle(fontSize: 20.sp),
              headlineSmall: TextStyle(fontSize: 18.sp),
              titleLarge: TextStyle(fontSize: 16.sp),
              titleMedium: TextStyle(fontSize: 14.sp),
              titleSmall: TextStyle(fontSize: 12.sp),
              bodyLarge: TextStyle(fontSize: 16.sp),
              bodyMedium: TextStyle(fontSize: 14.sp),
              bodySmall: TextStyle(fontSize: 12.sp),
              labelLarge: TextStyle(fontSize: 14.sp),
              labelMedium: TextStyle(fontSize: 12.sp),
              labelSmall: TextStyle(fontSize: 10.sp),
            ),
            // Responsive button theme
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(88.w, 48.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            // Responsive card theme
            cardTheme: CardThemeData(
              margin: EdgeInsets.all(8.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            // Responsive input decoration theme
            inputDecorationTheme: InputDecorationTheme(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          routes: {
            '/dashboard': (context) => const DashboardScreen(),
            '/home': (context) => const HomeScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signUp': (context) => const RegisterScreen(),
            '/booking': (context) => const BookingScreen(),
            '/rfid': (context) => const RFIDCardScreen(),
            '/rates': (context) => const RatesScreen(),
            '/FAQs': (context) => const FAQsScreen(),
            '/about': (context) => const AboutScreen(),
            '/forgotPassword': (context) => const ForgotPasswordScreen(),
            '/otp': (context) => const OTPScreen(),
            '/responsive-demo': (context) => const ResponsiveExampleScreen(),
          },
        );
      },
    );
  }
}

Future<bool> isTokenValid() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return false;
  return !JwtDecoder.isExpired(token);
}
