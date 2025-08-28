// ok na pero walang bi eye slash

import 'package:EcBarko/screens/terms_screen.dart';
import 'package:flutter/gestures.dart';

import '../constants.dart';
import '../widgets/customfont.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController mobilenumController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _headingAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _formAnimation;

  bool _isPasswordEntered = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  bool _isAccepted = false;
  final bool _otp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final bool _isButtonDisabled = false;
  final int _start = 120; // 3 minutes
  Timer? _timer;
  final GlobalKey _passwordFieldKey = GlobalKey();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFieldFocused = false;
  OverlayEntry? _overlayEntry;
  bool _isTooltipVisible = false;

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
    passwordController.addListener(_updatePasswordCriteria);
    confirmpasswordController.addListener(_updatePasswordCriteria);
    _controller.forward();

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFieldFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  void _updatePasswordCriteria() {
    setState(() {
      final text = passwordController.text;
      _isPasswordEntered = text.isNotEmpty;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(text);
      _hasNumber = RegExp(r'[0-9]').hasMatch(text);
      _hasSpecialChar = _containsSpecialCharacters(text);
      _hasMinLength = text.length >= 8;

      if (_isTooltipVisible) {
        _removePasswordTooltip();
        _showPasswordTooltip();
      }
    });
  }

  bool _containsSpecialCharacters(String password) {
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:\'",.<>/?';
    return password.split('').any((char) => specialChars.contains(char));
  }

  void _showPasswordTooltip() {
    if (_overlayEntry != null) _removePasswordTooltip();
    final RenderBox renderBox =
        _passwordFieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removePasswordTooltip,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx + 50,
              top: position.dy + size.height + 5,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Ec_DARK_PRIMARY.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password must have:',
                        style: TextStyle(
                          color: Color(0xFF1A1C29),
                          fontSize: 12,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildCriteriaItem(
                          'At least 8 characters', _hasMinLength),
                      _buildCriteriaItem(
                          'At least 1 uppercase character', _hasUppercase),
                      _buildCriteriaItem(
                          'At least 1 lowercase character', _hasLowercase),
                      _buildCriteriaItem('At least 1 number', _hasNumber),
                      _buildCriteriaItem(
                          'At least 1 special character e.g. ! @ # \$ %',
                          _hasSpecialChar),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _isTooltipVisible = true;
  }

  Widget _buildCriteriaItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle : Icons.circle_outlined,
              color: isValid ? Colors.green : Colors.red, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF1A1C29),
                    fontSize: 12,
                    fontFamily: 'Arial')),
          ),
        ],
      ),
    );
  }

  void _removePasswordTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isTooltipVisible = false;
  }

  void _togglePasswordTooltip() {
    if (_isTooltipVisible) {
      _removePasswordTooltip();
    } else {
      _showPasswordTooltip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    mobilenumController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    _removePasswordTooltip();
    super.dispose();
  }

  // Validators
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return "This field is required";
    if (value.length < 2) return "Name must be at least 2 characters";
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Mobile number is required";
    if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) {
      return "Enter a valid 11-digit mobile number";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecialChar =
        value.contains(RegExp(r'[!@#\$&*~%^()_+\-=\[\]{}|\\:;"\<>,.?/]'));

    if (!hasUppercase) {
      return 'Password must have at least one uppercase letter';
    }
    if (!hasLowercase) {
      return 'Password must have at least one lowercase letter';
    }
    if (!hasDigit) return 'Password must have at least one number';
    if (!hasSpecialChar) {
      return 'Password must have at least one special character';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return "Confirm your password";
    if (value != passwordController.text) return "Passwords do not match";
    return null;
  }

  // Main UI build
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
              'SIGN UP',
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
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Optional top info
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeTransition(
                                opacity: _headingAnimation,
                                child: const CustomFont(
                                  text:
                                      'Please fill in the details to register and create an account.',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Form container
                      Expanded(
                        flex: 10,
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
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                            child: FadeTransition(
                              opacity: _formAnimation,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First + Last Name
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Text('First Name',
                                              //     style: TextStyle(
                                              //         color: Colors.black,
                                              //         fontSize: ScreenUtil()
                                              //             .setSp(15))),
                                              _buildInputField(
                                                label: 'First Name',
                                                icon: Icons.person,
                                                controller: firstnameController,
                                                validator: validateName,
                                                maxLength: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width: ScreenUtil().setWidth(10)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Text('Last Name',
                                              //     style: TextStyle(
                                              //         color: Colors.black,
                                              //         fontSize: ScreenUtil()
                                              //             .setSp(15))),
                                              _buildInputField(
                                                label: 'Last Name',
                                                icon: Icons.person_outline,
                                                controller: lastnameController,
                                                validator: validateName,
                                                maxLength: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: ScreenUtil().setHeight(10)),
                                    // Email
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildInputField(
                                                label: 'Email Address',
                                                icon: Icons.email,
                                                controller: usernameController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                validator: validateEmail,
                                                readOnly: _otp,
                                                maxLength: 50,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                        height: ScreenUtil().setHeight(10)),
                                    // Mobile
                                    _buildInputField(
                                      label: 'Phone Number',
                                      icon: Icons.phone,
                                      controller: mobilenumController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 11,
                                      validator: validateMobile,
                                    ),
                                    SizedBox(
                                        height: ScreenUtil().setHeight(10)),
                                    // Password
                                    _buildInputField(
                                      label: 'Password',
                                      icon: Icons.lock,
                                      controller: passwordController,
                                      validator: validatePassword,
                                      obscureText: _obscurePassword,
                                      maxLength: 20,
                                      focusNode: _passwordFocusNode,
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
                                    if (_isPasswordFieldFocused)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '• Must have at least one uppercase letter',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Text(
                                                '• Must have at least one lowercase letter',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Text(
                                                '• Must have at least one number',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Text(
                                                '• Must have at least one special character',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    SizedBox(
                                        height: ScreenUtil().setHeight(10)),
                                    // Confirm Password
                                    _buildInputField(
                                      label: 'Confirm Password',
                                      icon: Icons.lock_outline,
                                      controller: confirmpasswordController,
                                      validator: validateConfirmPassword,
                                      obscureText: _obscureConfirmPassword,
                                      maxLength: 20,
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () {
                                          setState(() =>
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword);
                                        },
                                      ),
                                    ),
                                    // Checkbox Acceptance
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _isAccepted,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _isAccepted = value ?? false;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: 'I accept all the ',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'terms and conditions',
                                                  style: const TextStyle(
                                                    color: Ec_DARK_PRIMARY,
                                                    fontSize: 15,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const TermsScreen()),
                                                          );
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // // Checkbox Acceptance
                                    // Row(
                                    //   children: [
                                    //     Checkbox(
                                    //       value: _isAccepted,
                                    //       onChanged: (bool? value) {
                                    //         setState(() {
                                    //           _isAccepted = value ?? false;
                                    //         });
                                    //       },
                                    //     ),
                                    //     Expanded(
                                    //       child: GestureDetector(
                                    //         onTap: () {
                                    //           _showTermsAndConditions();
                                    //         },
                                    //         child: Text(
                                    //           'I accept all the terms and conditions',
                                    //           style: TextStyle(
                                    //             color: Colors.black,
                                    //             fontSize:
                                    //                 ScreenUtil().setSp(15),
                                    //             decoration:
                                    //                 TextDecoration.underline,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    SizedBox(
                                        height: ScreenUtil().setHeight(10)),
                                    // Submit Button
                                    CustomInkwellButton(
                                      onTap: () => _submit(),
                                      height: ScreenUtil().setHeight(45),
                                      width: ScreenUtil().screenWidth,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      buttonName: 'Submit',
                                    ),
                                    SizedBox(
                                        height: ScreenUtil().setHeight(20)),
                                    // Login redirect
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'You have an account?',
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Navigator.popAndPushNamed(
                                                  context, '/login'),
                                          child: Text(
                                            ' Login here',
                                            style: TextStyle(
                                              color: Ec_DARK_PRIMARY,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
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

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    required int maxLength,
    bool readOnly = false,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
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
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
      validator: validator,
      readOnly: readOnly,
    );
  }

  void _submit() async {
    if (!_isAccepted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Agreement Required",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              "Please read and accept the terms and conditions to continue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showTermsAndConditions(confirmBeforeAccept: true);
              },
              child: const Text("Read Terms"),
            ),
          ],
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('${getBaseUrl()}/api/register');
      final body = {
        'first_name': firstnameController.text.trim(),
        'last_name': lastnameController.text.trim(),
        'email': usernameController.text.trim(),
        'phone': mobilenumController.text.trim(),
        'password': passwordController.text.trim(),
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          sendOtp(usernameController.text.trim());
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Success",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text("Registration successful!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/otp');
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          final result = jsonDecode(response.body);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Registration Failed",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text(result['message'] ?? 'An error occurred.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Network Error",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text("Could not connect to server: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("All fields are required to continue."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
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

  void _showTermsAndConditions({bool confirmBeforeAccept = false}) {
    showDialog(
      context: context,
      barrierDismissible: !confirmBeforeAccept,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. We collect your data to improve your experience.'),
              SizedBox(height: 10),
              Text(
                  '2. Your data will be stored securely and not shared without consent.'),
              SizedBox(height: 10),
              Text(
                  '3. You agree to use the platform in good faith and respect others.'),
              SizedBox(height: 10),
              Text('4. These terms are subject to periodic updates.'),
              SizedBox(height: 10),
              Text('By continuing, you agree to these terms.'),
            ],
          ),
        ),
        actions: [
          if (confirmBeforeAccept)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isAccepted = true;
                });
              },
              child: const Text('I Agree'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(confirmBeforeAccept ? 'Cancel' : 'Close'),
          ),
        ],
      ),
    );
  }
}
