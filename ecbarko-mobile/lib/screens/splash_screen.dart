import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants.dart';
import 'welcome_screen.dart';

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

    // Animation controller for fading effect on "Loading..."
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _navigateToNext();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
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
            LoadingAnimationWidget.waveDots(
              color: Colors.white,
              size: 70,
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
