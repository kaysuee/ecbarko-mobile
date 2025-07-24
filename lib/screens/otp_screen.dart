import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart'; // Ensure this includes your color constants like Ec_DARK_PRIMARY

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart'; // Ensure this includes your color constants like Ec_DARK_PRIMARY
import 'package:http/http.dart' as http;
import 'dart:convert';

String getBaseUrl() {
  return 'https://ecbarko.onrender.com';
  // return 'http://localhost:3000';
}

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _headingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this, // This requires SingleTickerProviderStateMixin
    );
    _headingAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showSnackbar('Please enter the OTP');
      return;
    }

    final response = await http.post(
      Uri.parse('${getBaseUrl()}/api/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['verified'] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("OTP Verified!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      // Proceed to next screen or reset password
    } else {
      showSnackbar('Invalid OTP', Colors.red);
    }
  }

  void showSnackbar(String message, [Color color = Colors.red]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
              'OTP Verification',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: otpController,
                style: TextStyle(
                  // <== Put style here
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  labelStyle: TextStyle(color: Colors.white), // Optional
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white10, // optional background color
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyOtp,
                child: const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
