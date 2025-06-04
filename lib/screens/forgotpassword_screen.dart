import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart'; // Ensure this includes your color constants like Ec_DARK_PRIMARY
import 'package:http/http.dart' as http;
import 'dart:convert';


String getBaseUrl() {
    return 'https://ecbarko.onrender.com'; // Web
  
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headingAnimation;
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _controller.forward();
  }

void _sendResetLink() async {
  if (_formKey.currentState!.validate()) {
    final response = await http.post(
      Uri.parse('${getBaseUrl()}/api/send-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset link sent! Please check your email.'),
        backgroundColor: Colors.green,),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to send reset link.'),
        backgroundColor: Colors.red,),
      );
    }
  }
}

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    super.dispose();
  }

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
                 Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            title: const Text(
              'OTP',
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
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter your email to reset your password.',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Your email',
                                    hintStyle: TextStyle(fontSize: 15.sp),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email.';
                                    }
                                    // Your email validation here
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 30.h),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(size.width * 0.9, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _sendResetLink,
                                child: const Text('Send Reset Link'),
                              ),
                            ],
                          ),
                        ),
                        // You can add more UI here if needed
                      ],
                    ),
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
// import 'package:EcBarko/constants.dart';
// import 'package:flutter/material.dart';

// class ForgotPasswordScreen extends StatelessWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Your custom design here
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//         backgroundColor: Ec_DARK_PRIMARY, // Use your color constant
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 40),
//             const Text(
//               'Reset Your Password',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black, // Or your predefined color
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Please enter your email address to receive password reset instructions.',
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Your email',
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 // Implement your reset logic
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Reset instructions sent!')),
//                 );
//               },
//               child: const Text('Send Reset Link'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
