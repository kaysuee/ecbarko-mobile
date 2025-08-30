import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../constants.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../utils/date_format.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _opacityController;

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initializeApp();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Wait for 3 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      // Set up token expiration check
      Duration timeUntilExpiry =
          JwtDecoder.getExpirationDate(token).difference(DateFormatUtil.getCurrentTime());

      if (timeUntilExpiry.isNegative) {
        // Token is already expired
        await prefs.clear();
        _navigateToWelcome();
      } else {
        // Token is valid, navigate to home
        _navigateToHome();

        // Set up expiration check
        Future.delayed(timeUntilExpiry, () async {
          if (!mounted) return;
          await prefs.clear();
          _navigateToWelcome();
        });
      }
    } else {
      // No token or expired token
      await prefs.clear();
      _navigateToWelcome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_PRIMARY,
      body: Container(
        width: double.infinity,
        height: ScreenUtil().screenHeight,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Logo
            Image.asset(
              'assets/images/logoWhite.png',
              width: 250.w,
              height: 250.w,
              fit: BoxFit.contain,
            ),

            SizedBox(height: 40.h),

            /// waveDots loading animation
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4.0,
            ),

            SizedBox(height: 20.h),

            /// Fading "Loading..." text
            FadeTransition(
              opacity: Tween<double>(begin: 0.6, end: 1.0)
                  .animate(_opacityController),
              child: Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
