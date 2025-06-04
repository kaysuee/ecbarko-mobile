import 'package:EcBarko/screens/about_screen.dart';
import 'package:EcBarko/screens/forgotpassword_screen.dart';
import 'package:EcBarko/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
  final prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final token = prefs.getString('token');

  // Validate token if it exists
  if (token != null && JwtDecoder.isExpired(token)) {
    await prefs.clear();
    isLoggedIn = false;
  }

  runApp(EcBarkoMobile(isLoggedIn: isLoggedIn));
}

class EcBarkoMobile extends StatelessWidget {
  final bool isLoggedIn;

  const EcBarkoMobile({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EcBarko Mobile',
          initialRoute: '/splash',
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
