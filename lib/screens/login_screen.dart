import '../constants.dart';
import '../widgets/customfont.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _headingAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headingAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _cardAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    );
    _formAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  void submit() async {
    HapticFeedback.lightImpact();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        final response = await http.post(
          Uri.parse('${getBaseUrl()}/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['token'] != null) {
          final token = responseData['token'];
          final user = responseData['user'];
          if (user['status'] == "inactive") {
            sendOtp(emailController.text.trim());
            Navigator.pushReplacementNamed(context, '/otp');
            return;
          }
          print("badingss $user");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userID', user['userId']);
          await prefs.setString('token', token);
          await prefs.setString('email', user['email']);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          final errorMsg = responseData['error'] ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("bading $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid credentials.'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('${getBaseUrl()}/api/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['send'] == true) {
      print("otp sent");
    } else {
      print("OTP sent Error. Please try again!");
    }
  }

  // Uncomment this method if you want to use the dialog for success
  // void submit() {
  //   HapticFeedback.lightImpact();
  //   if (_formKey.currentState!.validate()) {
  //     setState(() => _isLoading = true);
  //     Future.delayed(const Duration(seconds: 2), () {
  //       setState(() => _isLoading = false);
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => Dialog(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //           child: SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.8,
  //             child: Padding(
  //               padding: const EdgeInsets.all(20),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // const Row(
  //                   //   children: [
  //                   //     Icon(Icons.check_circle, color: Colors.green),
  //                   //     SizedBox(width: 10),
  //                   //     Text("Success",
  //                   //         style: TextStyle(
  //                   //             fontWeight: FontWeight.bold, fontSize: 18)),
  //                   //   ],
  //                   // ),
  //                   // const SizedBox(height: 16),
  //                   // const Text(
  //                   //   "Login successful!",
  //                   //   style:
  //                   //       TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
  //                   // ),
  //                   const SizedBox(height: 24),
  //                   Align(
  //                     alignment: Alignment.centerRight,
  //                     child: TextButton(
  //                       style:
  //                           TextButton.styleFrom(foregroundColor: Colors.green),
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         Navigator.pushReplacementNamed(context, '/home');
  //                       },
  //                       child: const Text("Continue"),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Please enter valid credentials.'),
  //         backgroundColor: Colors.red[400],
  //         behavior: SnackBarBehavior.floating,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains("@")) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Helper widget for custom input fields
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: onTap,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100], // Light background
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  // // Helper widget for custom input fields with improved design
  // Widget _buildInputField({
  //   required String label,
  //   required IconData icon,
  //   required TextEditingController controller,
  //   bool obscureText = false,
  //   Widget? suffixIcon,
  //   String? Function(String?)? validator,
  //   VoidCallback? onTap,
  //   TextInputType keyboardType = TextInputType.text,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     obscureText: obscureText,
  //     keyboardType: keyboardType,
  //     onTap: onTap,
  //     validator: validator,
  //     style: TextStyle(
  //       fontSize: 15,
  //       fontWeight: FontWeight.w400,
  //       color: Colors.black87,
  //     ),
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.grey[100], // Light background
  //       prefixIcon: Icon(icon, color: Colors.grey[600]),
  //       suffixIcon: suffixIcon,
  //       labelText: label,
  //       labelStyle: TextStyle(
  //         fontSize: 14,
  //         color: Colors.grey[800],
  //       ),
  //       contentPadding:
  //           const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(color: Colors.grey[300]!),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(color: Colors.blueAccent),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Ec_DARK_PRIMARY,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: FadeTransition(
          opacity: _headingAnimation,
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/welcome');
              },
            ),
            title: const Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Ec_DARK_PRIMARY,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _headingAnimation,
                              child: const CustomFont(
                                text:
                                    'Please enter your credentials to access your account.',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.5), end: Offset.zero)
                              .animate(_cardAnimation),
                          child: Container(
                            width: size.width,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(44),
                                topRight: Radius.circular(44),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                            child: FadeTransition(
                              opacity: _formAnimation,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email Input
                                    _buildInputField(
                                      label: 'Email',
                                      icon: Icons.email,
                                      controller: emailController,
                                      validator: validateEmail,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: 20),
                                    // Password Input
                                    _buildInputField(
                                      label: 'Password',
                                      icon: Icons.lock,
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      validator: validatePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () {
                                          setState(() => _obscurePassword =
                                              !_obscurePassword);
                                        },
                                      ),
                                    ),

                                    SizedBox(height: 10),
                                    // Forgot Password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/forgotPassword');
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontFamily: 'Arial',
                                            fontWeight: FontWeight.w400,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // Login Button
                                    CustomInkwellButton(
                                      onTap: _isLoading ? null : submit,
                                      height: ScreenUtil().setHeight(50),
                                      width: ScreenUtil().screenWidth * 0.9,
                                      buttonName: _isLoading
                                          ? 'Logging in...'
                                          : 'Login',
                                      fontSize: ScreenUtil().setSp(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // const SizedBox(height: 20),
                                    // // OR LOG IN WITH
                                    // const Text(
                                    //   'OR LOG IN WITH',
                                    //   style: TextStyle(
                                    //       fontSize: 14,
                                    //       color: Color(0xFF797979),
                                    //       fontWeight: FontWeight.w600),
                                    // ),
                                    // const SizedBox(height: 20),
                                    // // Google Login Button
                                    // ElevatedButton(
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Ec_BG_SOFT_BLUE,
                                    //     foregroundColor: Ec_BLACK,
                                    //     elevation: 2,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(12),
                                    //     ),
                                    //     minimumSize: Size(size.width * 0.9, 50),
                                    //   ),
                                    //   onPressed: () {
                                    //     // Handle Google login
                                    //   },
                                    //   child: const Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.center,
                                    //     children: [
                                    //       Icon(Icons.g_mobiledata,
                                    //           size: 24, color: Ec_DARK_PRIMARY),
                                    //       SizedBox(width: 12),
                                    //       Text('Login with Google',
                                    //           style: TextStyle(fontSize: 16)),
                                    //     ],
                                    //   ),
                                    // ),
                                    const SizedBox(height: 20),
                                    // Sign Up link
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/signUp');
                                      },
                                      child: const Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Don’t have an account yet? ',
                                              style: TextStyle(
                                                color: Color(0xFF797979),
                                                fontSize: 14,
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Create one.',
                                              style: TextStyle(
                                                color: Ec_DARK_PRIMARY,
                                                fontSize: 14,
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
