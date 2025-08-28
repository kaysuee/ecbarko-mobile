import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class LinkedCardScreen extends StatefulWidget {
  const LinkedCardScreen({super.key});

  @override
  State<LinkedCardScreen> createState() => _LinkedCardScreenState();
}

class _LinkedCardScreenState extends State<LinkedCardScreen>
    with TickerProviderStateMixin {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardLabelController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isCardNumberValid = false;
  bool _isCardLabelValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    // Add listeners for real-time validation
    cardNumberController.addListener(_validateCardNumber);
    cardLabelController.addListener(_validateCardLabel);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    cardNumberController.dispose();
    cardLabelController.dispose();
    super.dispose();
  }

  void _validateCardNumber() {
    final cardNumber = cardNumberController.text.trim();
    final digitsOnly = cardNumber.replaceAll('-', '');
    setState(() {
      _isCardNumberValid = digitsOnly.length == 12;
    });
  }

  void _validateCardLabel() {
    setState(() {
      _isCardLabelValid = cardLabelController.text.trim().isNotEmpty;
    });
  }

  String _formatCardNumber(String text) {
    final digitsOnly = text.replaceAll('-', '');
    if (digitsOnly.length <= 4) return digitsOnly;
    if (digitsOnly.length <= 8)
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4)}';
    return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 8)}-${digitsOnly.substring(8)}';
  }

  Future<void> _saveCard() async {
    if (!_isCardNumberValid) return;

    setState(() => _isLoading = true);

    final cardNumber = cardNumberController.text.trim();
    final cardLabel = cardLabelController.text.trim();
    final digitsOnly = cardNumber.replaceAll('-', '');

    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('userID');
    final url = Uri.parse('${getBaseUrl()}/api/card/$cardNumber');
    final body = {
      'userId': user,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userID');

        if (userId != null) {
          await NotificationService.notifyCardLinked(
            userId: userId,
            cardType: cardLabel.isNotEmpty ? cardLabel : 'EcBarko Card',
            cardNumber: cardNumber,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Card linked successfully!',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to link card. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please check your connection.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: Text(
          'Link ECBARKO Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(20),
        //   ),
        // ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // Hero Section
                // _buildHeroSection(),
                // SizedBox(height: 30.h),

                // Card Number Section
                _buildCardNumberSection(),
                SizedBox(height: 24.h),

                // Card Label Section
                _buildCardLabelSection(),
                SizedBox(height: 30.h),

                // // Info Section
                // _buildInfoSection(),
                // SizedBox(height: 40.h),

                // Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeroSection() {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.all(24.w),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Ec_PRIMARY.withOpacity(0.1),
  //           Ec_PRIMARY.withOpacity(0.05),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(20.r),
  //       border: Border.all(
  //         color: Ec_PRIMARY.withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(16.w),
  //           decoration: BoxDecoration(
  //             color: Ec_PRIMARY.withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(
  //             Icons.credit_card_rounded,
  //             size: 20.sp,
  //             color: Ec_PRIMARY,
  //           ),
  //         ),
  //         SizedBox(height: 16.h),
  //         Text(
  //           'Link Your ECBARKO Card',
  //           style: TextStyle(
  //             fontSize: 15.sp,
  //             fontWeight: FontWeight.bold,
  //             color: Ec_PRIMARY,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           'Connect your physical card to your digital account',
  //           style: TextStyle(
  //             fontSize: 12.sp,
  //             color: Colors.grey[600],
  //             height: 1.4,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCardNumberSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                size: 20.sp,
                color: Ec_PRIMARY,
              ),
              SizedBox(width: 8.w),
              Text(
                'Card Number',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              if (_isCardNumberValid)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20.sp,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Enter the last 12 digits of your ECBARKO card',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 14, // 12 digits + 2 hyphens
            onChanged: (value) {
              final formatted = _formatCardNumber(value);
              if (formatted != value) {
                cardNumberController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
            decoration: InputDecoration(
              hintText: '1234-5678-9012',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: _isCardNumberValid ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Ec_PRIMARY,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              prefixIcon: Icon(
                Icons.credit_card_outlined,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLabelSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label,
                size: 20.sp,
                color: Ec_PRIMARY,
              ),
              SizedBox(width: 8.w),
              Text(
                'Card Label',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              if (_isCardLabelValid)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20.sp,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Give your card a memorable name (optional)',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: cardLabelController,
            decoration: InputDecoration(
              hintText: 'e.g., My Main Card, Work Card',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: _isCardLabelValid ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Ec_PRIMARY,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              prefixIcon: Icon(
                Icons.label_outline,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildInfoSection() {
  //   return Container(
  //     padding: EdgeInsets.all(20.w),
  //     decoration: BoxDecoration(
  //       color: Colors.blue[50],
  //       borderRadius: BorderRadius.circular(16.r),
  //       border: Border.all(
  //         color: Colors.blue[200]!,
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.info_outline,
  //           color: Colors.blue[600],
  //           size: 24.sp,
  //         ),
  //         SizedBox(width: 16.w),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Why link your card?',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.blue[800],
  //                 ),
  //               ),
  //               SizedBox(height: 4.h),
  //               Text(
  //                 '• Quick access to your card details\n• Secure digital management\n• Easy transaction tracking',
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   color: Colors.blue[700],
  //                   height: 1.4,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSaveButton() {
    final isValid = _isCardNumberValid;

    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Ec_PRIMARY,
        // boxShadow: [
        //   BoxShadow(
        //     color: Ec_PRIMARY.withOpacity(0.3),
        //     blurRadius: 20,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? Ec_PRIMARY : Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        onPressed: isValid && !_isLoading ? _saveCard : null,
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Link Card',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
