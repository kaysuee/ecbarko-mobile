import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:EcBarko/constants.dart';
import '../widgets/customfont.dart';
import '../widgets/custom_inkwell_button.dart';
import 'terms_screen.dart'; // Import the TermsScreen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _termsAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );

    _termsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Ec_DARK_PRIMARY,
      body: Column(
        children: [
          const Spacer(flex: 2),

          // Logo
          ScaleTransition(
            scale: _logoAnimation,
            child: FadeTransition(
              opacity: _logoAnimation,
              child: Image.asset(
                'assets/images/logoWhite.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Bottom white container
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(_controller),
            child: Container(
              width: size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                ),
              ),
              padding: const EdgeInsets.only(
                  top: 25, left: 25, right: 25, bottom: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _textAnimation,
                    child: const CustomFont(
                      text: 'Welcome',
                      fontSize: 36,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FadeTransition(
                    opacity: _textAnimation,
                    child: const CustomFont(
                      text:
                          'Welcome to EcBarko! Please log in to access your account or sign up if you are a new user.',
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  FadeTransition(
                    opacity: _buttonAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomInkwellButton(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            height: 62,
                            width: double.infinity,
                            buttonName: 'Login',
                            fontSize: 20,
                            bgColor: const Color(0xFF013986),
                            fontColor: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomInkwellButton(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/signUp');
                            },
                            height: 62,
                            width: double.infinity,
                            buttonName: 'Sign Up',
                            fontSize: 20,
                            bgColor: const Color(0xFF1E1E1E),
                            fontColor: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Terms & Conditions
                  FadeTransition(
                    opacity: _termsAnimation,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'If you are creating a new account, ',
                              style: TextStyle(
                                color: Ec_TEXT_COLOR_GREY,
                                fontSize: 12,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                height: 1.67,
                              ),
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: Ec_DARK_PRIMARY,
                                fontSize: 12,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                                height: 1.67,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to TermsScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const TermsScreen()),
                                  );
                                },
                            ),
                            const TextSpan(
                              text: ' will apply.',
                              style: TextStyle(
                                color: Ec_TEXT_COLOR_GREY,
                                fontSize: 12,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                height: 1.67,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//eto yung code bago ko palitan
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:EcBarko/constants.dart';
// import '../widgets/customfont.dart';
// import '../widgets/custom_inkwell_button.dart';

// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _logoAnimation;
//   late Animation<double> _cardAnimation;
//   late Animation<double> _textAnimation;
//   late Animation<double> _buttonAnimation;
//   late Animation<double> _termsAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _logoAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
//     );

//     _cardAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
//     );

//     _textAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
//     );

//     _buttonAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
//     );

//     _termsAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final safeArea = MediaQuery.of(context).padding;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Ec_DARK_PRIMARY,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: size.height - safeArea.top - safeArea.bottom,
//             ),
//             child: IntrinsicHeight(
//               child: Column(
//                 children: [
//                   // Logo section
//                   Expanded(
//                     flex: 3,
//                     child: ScaleTransition(
//                       scale: _logoAnimation,
//                       child: FadeTransition(
//                         opacity: _logoAnimation,
//                         child: Center(
//                           child: Image.asset(
//                             'assets/images/logoWhite.png',
//                             width: 250,
//                             height: 250,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Content section
//                   Expanded(
//                     flex: 2,
//                     child: SlideTransition(
//                       position: Tween<Offset>(
//                         begin: const Offset(0, 1),
//                         end: Offset.zero,
//                       ).animate(_cardAnimation),
//                       child: Container(
//                         width: size.width,
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(44),
//                             topRight: Radius.circular(44),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Welcome text
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 25, top: 25, bottom: 10),
//                               child: FadeTransition(
//                                 opacity: _textAnimation,
//                                 child: const CustomFont(
//                                   text: 'Welcome',
//                                   fontSize: 36,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),

//                             // Description
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 25),
//                               child: FadeTransition(
//                                 opacity: _textAnimation,
//                                 child: const CustomFont(
//                                   text:
//                                       'Welcome to EcBarko! Please log in to access your account or sign up if you are a new user.',
//                                   fontSize: 15,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),

//                             const Spacer(),

//                             // Buttons
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 25, vertical: 20),
//                               child: FadeTransition(
//                                 opacity: _buttonAnimation,
//                                 child: SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: const Offset(0, 0.2),
//                                     end: Offset.zero,
//                                   ).animate(_buttonAnimation),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: CustomInkwellButton(
//                                           onTap: () {
//                                             Navigator.pushReplacementNamed(
//                                                 context, '/login');
//                                           },
//                                           height: 62,
//                                           width: double.infinity,
//                                           buttonName: 'Login',
//                                           fontSize: 20,
//                                           bgColor: const Color(0xFF013986),
//                                           fontColor: Colors.white,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       Expanded(
//                                         child: CustomInkwellButton(
//                                           onTap: () {
//                                             Navigator.pushReplacementNamed(
//                                                 context, '/signUp');
//                                           },
//                                           height: 62,
//                                           width: double.infinity,
//                                           buttonName: 'Sign Up',
//                                           fontSize: 20,
//                                           bgColor: const Color(0xFF1E1E1E),
//                                           fontColor: Colors.white,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             // Terms
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 30),
//                               child: FadeTransition(
//                                 opacity: _termsAnimation,
//                                 child: Center(
//                                   child: RichText(
//                                     textAlign: TextAlign.center,
//                                     text: TextSpan(
//                                       children: [
//                                         const TextSpan(
//                                           text:
//                                               'If you are creating a new account, \n',
//                                           style: TextStyle(
//                                             color: Ec_TEXT_COLOR_GREY,
//                                             fontSize: 12,
//                                             fontFamily: 'SF Pro',
//                                             fontWeight: FontWeight.w400,
//                                             height: 1.67,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: 'Terms & Conditions',
//                                           style: const TextStyle(
//                                             color: Ec_DARK_PRIMARY,
//                                             fontSize: 12,
//                                             fontFamily: 'SF Pro',
//                                             fontWeight: FontWeight.w400,
//                                             decoration:
//                                                 TextDecoration.underline,
//                                             height: 1.67,
//                                           ),
//                                           recognizer: TapGestureRecognizer()
//                                             ..onTap = () {
//                                               // Handle terms tap
//                                             },
//                                         ),
//                                         const TextSpan(
//                                           text: ' and ',
//                                           style: TextStyle(
//                                             color: Ec_TEXT_COLOR_GREY,
//                                             fontSize: 12,
//                                             fontFamily: 'SF Pro',
//                                             fontWeight: FontWeight.w400,
//                                             height: 1.67,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: 'Privacy Policy',
//                                           style: const TextStyle(
//                                             color: Ec_DARK_PRIMARY,
//                                             fontSize: 12,
//                                             fontFamily: 'SF Pro',
//                                             fontWeight: FontWeight.w400,
//                                             decoration:
//                                                 TextDecoration.underline,
//                                             height: 1.67,
//                                           ),
//                                           recognizer: TapGestureRecognizer()
//                                             ..onTap = () {
//                                               // Handle privacy policy tap
//                                             },
//                                         ),
//                                         const TextSpan(
//                                           text: ' will apply.',
//                                           style: TextStyle(
//                                             color: Ec_TEXT_COLOR_GREY,
//                                             fontSize: 12,
//                                             fontFamily: 'SF Pro',
//                                             fontWeight: FontWeight.w400,
//                                             height: 1.67,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:EcBarko/constants.dart';
// import '../widgets/customfont.dart';
// import '../widgets/custom_inkwell_button.dart';

// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _logoAnimation;
//   late Animation<double> _cardAnimation;
//   late Animation<double> _textAnimation;
//   late Animation<double> _buttonAnimation;
//   late Animation<double> _termsAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Setup animation controller with 1.5 second duration
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     // Create staggered animations for different elements
//     _logoAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
//     );

//     _cardAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
//     );

//     _textAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
//     );

//     _buttonAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
//     );

//     _termsAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
//     );

//     // Start animation
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final safeArea = MediaQuery.of(context).padding;

//     return Scaffold(
//       backgroundColor: Ec_DARK_PRIMARY,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Logo section
//             Expanded(
//               flex: 3,
//               child: ScaleTransition(
//                 scale: _logoAnimation,
//                 child: FadeTransition(
//                   opacity: _logoAnimation,
//                   child: Center(
//                     child: Image.asset(
//                       'assets/images/logoWhite.png',
//                       width: 250,
//                       height: 250,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Content section
//             Expanded(
//               flex: 2, //Height of White Container
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   // White background card with animation
//                   SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0, 1),
//                       end: Offset.zero,
//                     ).animate(_cardAnimation),
//                     child: Container(
//                       width: size.width,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(44),
//                           topRight: Radius.circular(44),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Welcome text with animation
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 25, top: 25, bottom: 10),
//                             child: FadeTransition(
//                               opacity: _textAnimation,
//                               child: const CustomFont(
//                                 text: 'Welcome',
//                                 fontSize: 36,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                           // Description text with animation
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 25),
//                             child: FadeTransition(
//                               opacity: _textAnimation,
//                               child: const CustomFont(
//                                 text:
//                                     'Welcome to EcBarko! Please log in to access your account or sign up if you are a new user.',
//                                 fontSize: 15,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),

//                           const Spacer(),

//                           // Buttons with animation
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 25, vertical: 20),
//                             child: FadeTransition(
//                               opacity: _buttonAnimation,
//                               child: SlideTransition(
//                                 position: Tween<Offset>(
//                                   begin: const Offset(0, 0.2),
//                                   end: Offset.zero,
//                                 ).animate(_buttonAnimation),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: CustomInkwellButton(
//                                         onTap: () {
//                                           Navigator.pushReplacementNamed(
//                                               context, '/login');
//                                         },
//                                         height: 62,
//                                         width: double.infinity,
//                                         buttonName: 'Login',
//                                         fontSize: 20,
//                                         bgColor: const Color(0xFF013986),
//                                         fontColor: Colors.white,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: CustomInkwellButton(
//                                         onTap: () {
//                                           Navigator.pushReplacementNamed(
//                                               context, '/signUp');
//                                         },
//                                         height: 62,
//                                         width: double.infinity,
//                                         buttonName: 'Sign Up',
//                                         fontSize: 20,
//                                         bgColor: const Color(0xFF1E1E1E),
//                                         fontColor: Colors.white,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                           // Terms and conditions with animation
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 30),
//                             child: FadeTransition(
//                               opacity: _termsAnimation,
//                               child: Center(
//                                 child: RichText(
//                                   textAlign: TextAlign.center,
//                                   text: TextSpan(
//                                     children: [
//                                       const TextSpan(
//                                         text:
//                                             'If you are creating a new account, \n',
//                                         style: TextStyle(
//                                           color: Ec_TEXT_COLOR_GREY,
//                                           fontSize: 12,
//                                           fontFamily: 'SF Pro',
//                                           fontWeight: FontWeight.w400,
//                                           height: 1.67,
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: 'Terms & Conditions',
//                                         style: const TextStyle(
//                                           color: Ec_DARK_PRIMARY,
//                                           fontSize: 12,
//                                           fontFamily: 'SF Pro',
//                                           fontWeight: FontWeight.w400,
//                                           decoration: TextDecoration.underline,
//                                           height: 1.67,
//                                         ),
//                                         recognizer: TapGestureRecognizer()
//                                           ..onTap = () {
//                                             // Handle terms tap
//                                           },
//                                       ),
//                                       const TextSpan(
//                                         text: ' and ',
//                                         style: TextStyle(
//                                           color: Ec_TEXT_COLOR_GREY,
//                                           fontSize: 12,
//                                           fontFamily: 'SF Pro',
//                                           fontWeight: FontWeight.w400,
//                                           height: 1.67,
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: 'Privacy Policy',
//                                         style: const TextStyle(
//                                           color: Ec_DARK_PRIMARY,
//                                           fontSize: 12,
//                                           fontFamily: 'SF Pro',
//                                           fontWeight: FontWeight.w400,
//                                           decoration: TextDecoration.underline,
//                                           height: 1.67,
//                                         ),
//                                         recognizer: TapGestureRecognizer()
//                                           ..onTap = () {
//                                             // Handle privacy policy tap
//                                           },
//                                       ),
//                                       const TextSpan(
//                                         text: ' will apply.',
//                                         style: TextStyle(
//                                           color: Ec_TEXT_COLOR_GREY,
//                                           fontSize: 12,
//                                           fontFamily: 'SF Pro',
//                                           fontWeight: FontWeight.w400,
//                                           height: 1.67,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
