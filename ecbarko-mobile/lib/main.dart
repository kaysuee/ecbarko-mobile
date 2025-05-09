import 'package:EcBarko/screens/about_screen.dart';
import 'package:EcBarko/screens/forgotpassword_screen.dart';
import 'package:EcBarko/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Import your forgot password screen

import '/screens/home_screen.dart';
import '/screens/dashboard_screen.dart';
import '/screens/splash_screen.dart';
import 'package:EcBarko/screens/login_screen.dart';
import 'package:EcBarko/screens/register_screen.dart';
import 'package:EcBarko/screens/booking_screen.dart';
import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/rates_screen.dart';
import 'package:EcBarko/screens/FAQs_screen.dart';

void main() => runApp(const EcBarkoMobile());

class EcBarkoMobile extends StatelessWidget {
  const EcBarkoMobile({super.key});

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
            '/booking': (context) => const BookingsScreen(),
            '/rfid': (context) => const RFIDCardScreen(),
            '/rates': (context) => const RatesScreen(),
            '/FAQs': (context) => const FAQsScreen(),
            '/about': (context) => const AboutScreen(),
            // Add the route for ForgotPassword
            '/forgotPassword': (context) => const ForgotPasswordScreen(),
          },
        );
      },
    );
  }
}
// import 'package:EcBarko/screens/about_screen.dart';
// import 'package:EcBarko/screens/welcome_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '/screens/home_screen.dart';
// import '/screens/dashboard_screen.dart';
// import '/screens/splash_screen.dart';
// import 'package:EcBarko/screens/login_screen.dart';
// import 'package:EcBarko/screens/register_screen.dart';
// import 'package:EcBarko/screens/booking_screen.dart';
// import 'package:EcBarko/screens/RFIDCard_screen.dart';
// import 'package:EcBarko/screens/rates_screen.dart';
// import 'package:EcBarko/screens/FAQs_screen.dart';

// void main() => runApp(const EcBarkoMobile());

// class EcBarkoMobile extends StatelessWidget {
//   const EcBarkoMobile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(412, 715),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (_, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'EcBarko Mobile',
//           initialRoute: '/splash',
//           routes: {
//             '/dashboard': (context) => const DashboardScreen(),
//             '/home': (context) => const HomeScreen(),
//             '/welcome': (context) => const WelcomeScreen(),
//             '/splash': (context) => const SplashScreen(),
//             '/login': (context) => const LoginScreen(),
//             '/signUp': (context) => const RegisterScreen(),
//             '/booking': (context) => const BookingsScreen(),
//             '/rfid': (context) => const RFIDCardScreen(),
//             '/rates': (context) => const RatesScreen(),
//             '/FAQs': (context) => const FAQsScreen(),
//             '/about': (context) => const AboutScreen(),
//           },
//         );
//       },
//     );
//   }
// }
