import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/widgets/bounce_tap_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/payment_card.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this package for QR code generation
import 'dart:math'
    show Random, min; // For generating transaction IDs and min function

import 'package:EcBarko/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/notification_service.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class BuyLoadScreen extends StatefulWidget {
  const BuyLoadScreen({super.key});

  @override
  State<BuyLoadScreen> createState() => _BuyLoadScreenState();
}

class _BuyLoadScreenState extends State<BuyLoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController loadAmountController = TextEditingController();
  bool isBalanceVisible = true;
  bool isCustomAmount = false;
  Map<String, dynamic>? cardData;
  // Preset load amounts
  final List<int> presetAmounts = [300, 500, 1000, 3000, 5000];
  int? selectedAmount;
  double amountValue = 0.0;
  String? selectedPaymentMethod; // Add this line for payment method selection

  @override
  void initState() {
    super.initState();
    print('🚀 BuyLoadScreen initState called');
    try {
      // Start with the first preset amount selected
      selectedAmount = presetAmounts[0];
      loadAmountController.text = selectedAmount.toString();
      print('✅ BuyLoadScreen initialization successful');
      _loadCard();
    } catch (e) {
      print('❌ BuyLoadScreen initialization failed: $e');
    }
  }

  Future<void> _loadCard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/card/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cardData = jsonDecode(response.body);
        });
      } else {
        print('Failed to load card data: ${response.statusCode}');
      }
    }
  }

  Future<void> _buyload() async {
    // Safety check to ensure amountValue is valid
    if (amountValue <= 0) {
      print('Invalid amount value: $amountValue');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');
    print("here: $amountValue");
    if (token != null && userId != null) {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/buyload/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amountValue}),
      );

      if (response.statusCode == 200) {
        // Send card loaded notification
        await NotificationService.notifyCardLoaded(
          userId: userId,
          amount: amountValue,
          cardType: cardData?['cardType'] ?? 'EcBarko Card',
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FFFE),
                    Color(0xFFE8F5E8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon with Animation
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Success Title
                  Text(
                    'SUCCESS!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Success Message
                  Text(
                    'Buy Load Successful!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Transaction Details Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSuccessDetailRow(
                          'Amount Loaded:',
                          '₱${amountValue.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                        SizedBox(height: 12.h),
                        _buildSuccessDetailRow(
                          'Card Type:',
                          cardData?['cardType']?.toString() ?? 'EcBarko Card',
                          Icons.credit_card,
                          Ec_PRIMARY,
                        ),
                        SizedBox(height: 12.h),
                        _buildSuccessDetailRow(
                          'New Balance:',
                          '₱${((double.tryParse(cardData?['balance']?.toString() ?? '0') ?? 0) + amountValue).toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Success Message
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green[600],
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Your RFID card has been loaded successfully! You can now use it for your trips.',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      label: Text(
                        'Go to Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_PRIMARY,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        print('Failed to buy load card: ${response.statusCode}');

        // Show improved error dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF8F8),
                    Color(0xFFFFE8E8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error Icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Error Title
                  Text(
                    'Oops!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Error Message
                  Text(
                    'Failed to process payment',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Error Details
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red[600],
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Please try again or contact support if the problem persists.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      label: Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  void navigateToPaymentScreen(String paymentMethod) {
    if (isCustomAmount) {
      if (_formKey.currentState!.validate()) {
        String finalAmount = loadAmountController.text;

        if (paymentMethod == "QRPH") {
          _showQRPHPaymentSheet(finalAmount);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentCard(
                amount: finalAmount,
                paymentMethod: paymentMethod,
              ),
            ),
          );
        }
      }
    } else if (selectedAmount != null) {
      if (paymentMethod == "QRPH") {
        _showQRPHPaymentSheet(selectedAmount.toString());
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentCard(
              amount: selectedAmount.toString(),
              paymentMethod: paymentMethod,
            ),
          ),
        );
      }
    }
  }

  // QRPH Payment Integration
  // Add this to your BuyLoadScreen class to create a proper QR code:
  void _showQRPHPaymentSheet(String amount) {
    // Generate a transaction ID
    final String transactionId = _generateTransactionId();

    // Safe parsing of amount with error handling
    try {
      amountValue = double.parse(amount);
      if (amountValue <= 0) {
        throw FormatException('Amount must be greater than 0');
      }
    } catch (e) {
      print('Error parsing amount: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid amount: $amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create QR Code data
    final String qrData = _generateQRData(transactionId, amountValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              // height: MediaQuery.of(context).size.height * 0.8,
              // height: min(MediaQuery.of(context).size.height * 0.85, 700.h),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Handle
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 60.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Title
                  Text(
                    'QR PH Payment',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Scan this QR code with your banking app',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10.h),
// Smaller Amount Information Container
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 10.h), // reduced padding
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF),
                      borderRadius:
                          BorderRadius.circular(6.r), // smaller corner radius
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Amount to Pay:',
                            style: TextStyle(
                              fontSize: 10.sp, // smaller label font
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 3.h), // reduced spacing
                          Text(
                            '₱${amountValue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20.sp, // smaller amount font
                              fontWeight: FontWeight.w600,
                              color: Ec_PRIMARY,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // QR Code Container - THIS IS THE KEY PART TO FIX
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: min(180.w, MediaQuery.of(context).size.width * 0.5),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Transaction details
                  Text(
                    'Transaction ID: $transactionId',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Merchant: EcBarko RFID Loading',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 20.h),
                  // Smaller Instructions Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.w), // reduced padding
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF),
                      borderRadius: BorderRadius.circular(
                          8.r), // slightly smaller corner radius
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to pay',
                          style: TextStyle(
                            fontSize: 14.sp, // smaller title font
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6.h), // reduced spacing
                        _buildInstructionStep(
                          '1',
                          'Open your banking app with QR scan feature',
                          const Color(0xFF002C71),
                        ),
                        SizedBox(height: 5.h),
                        _buildInstructionStep(
                          '2',
                          'Scan this QR code',
                          const Color(0xFF002C71),
                        ),
                        SizedBox(height: 5.h),
                        _buildInstructionStep(
                          '3',
                          'Confirm payment details and complete transaction',
                          const Color(0xFF002C71),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h), // reduced spacing below
                  // Add Load Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Show confirmation dialog before proceeding
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.payment,
                                        color: Ec_PRIMARY,
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Confirm Payment',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Please confirm the following details:',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      _buildConfirmationRow(
                                        'Payment Method:',
                                        'QR PH',
                                        Icons.qr_code,
                                        Ec_PRIMARY,
                                      ),
                                      SizedBox(height: 8.h),
                                      _buildConfirmationRow(
                                        'Amount:',
                                        '₱${amountValue.toStringAsFixed(2)}',
                                        Icons.attach_money,
                                        Colors.green,
                                      ),
                                      SizedBox(height: 8.h),
                                      _buildConfirmationRow(
                                        'Transaction ID:',
                                        transactionId,
                                        Icons.receipt,
                                        Colors.orange,
                                      ),
                                      SizedBox(height: 16.h),
                                      Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                              color: Colors.blue[200]!),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue[600],
                                              size: 16.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                'Please ensure you have completed the QR PH payment before confirming.',
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close dialog
                                        Navigator.pop(
                                            context); // Close payment sheet
                                        _buyload(); // Proceed with loading
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Ec_PRIMARY,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: Text(
                                        'Confirm & Load',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          label: Text(
                            'Add Load',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Ec_PRIMARY,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w), // spacing between buttons

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red[400],
                            size: 18.sp,
                          ),
                          label: Text(
                            'Cancel Payment',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to generate a transaction ID
  String _generateTransactionId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final result = StringBuffer();

    for (var i = 0; i < 10; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }

    return result.toString();
  }

  // Generate QR data for QRPH
  String _generateQRData(String transactionId, double amount) {
    // This is a simplified version - in production, you would follow the QRPH standard format
    return 'QRPH|EcBarko|$transactionId|$amount|RFID Load';
  }

// Instruction step widget
  Widget _buildInstructionStep(String number, String text, Color circleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Select preset amount or enable custom amount entry
  void _selectAmount(int? amount) {
    setState(() {
      if (amount == null) {
        // User wants to enter a custom amount
        isCustomAmount = true;
        selectedAmount = null;
        loadAmountController.clear();
      } else {
        // User selected a preset amount
        isCustomAmount = false;
        selectedAmount = amount;
        loadAmountController.text = amount.toString();
      }
    });
  }

  Widget _buildRFIDImage(BuildContext context) {
    print('🖼️ Building RFID Image...');
    try {
      return BounceTapWrapper(
        onTap: () =>
            _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
        child: Card(
          color: Ec_PRIMARY,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 8,
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Container(
            width: double.infinity,
            // height: 220.h,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFF1A5A91),
                  Color(0xFF142F60),
                ],
                stops: [0.3, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logoWhite.png',
                      width: 50.w, // reduced from 60.w to 50.w
                      height: 50.w,
                    ),
                    Text(
                      'RFID CARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp, // reduced from 25.sp to 22.sp
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16.sp, // reduced from 18.sp to 16.sp
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isBalanceVisible = !isBalanceVisible;
                        });
                      },
                      child: Icon(
                        isBalanceVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.8),
                        size: 18.sp, // reduced from 20.sp to 18.sp
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  child: Text(
                    isBalanceVisible == true
                        ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
                        : '•••••••••',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp, // reduced from 40.sp to 28.sp
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error in _buildRFIDImage: $e');
      print('❌ Stack trace: $stackTrace');
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error building RFID image: $e'),
          ],
        ),
      );
    }
  }

  // Widget _buildRFIDImage(BuildContext context) {
  //   return BounceTapWrapper(
  //     onTap: () =>
  //         _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
  //     child: Card(
  //       color: Ec_PRIMARY,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       elevation: 8,
  //       margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
  //       child: Container(
  //         width: double.infinity,
  //         height: 220.h,
  //         padding: EdgeInsets.all(18.w),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(16.r),
  //           gradient: const RadialGradient(
  //             center: Alignment.center,
  //             radius: 1.0,
  //             colors: [
  //               Color(0xFF1A5A91),
  //               Color(0xFF142F60),
  //             ],
  //             stops: [0.3, 1.0],
  //           ),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Image.asset(
  //                   'assets/images/logoWhite.png',
  //                   width: 60.w,
  //                   height: 60.w,
  //                 ),
  //                 Text(
  //                   'RFID CARD',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 25.sp,
  //                     fontWeight: FontWeight.w700,
  //                     letterSpacing: 1.2,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 30.h),
  //             Text(
  //               'Available Balance',
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(0.9),
  //                 fontSize: 25.sp,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             SizedBox(height: 4.h),
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   isBalanceVisible == true
  //                       ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
  //                       : '•••••••••',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 40.sp,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 SizedBox(width: 8.w),
  //                 GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       isBalanceVisible = !isBalanceVisible;
  //                     });
  //                   },
  //                   child: Icon(
  //                     isBalanceVisible
  //                         ? Icons.visibility
  //                         : Icons.visibility_off,
  //                     color: Colors.white.withOpacity(0.8),
  //                     size: 25.sp,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Helper method for card action buttons
  Widget _buildCardActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // THIRD DESIGN OPTION: Large segmented buttons with icons
  Widget _buildPresetAmountButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset amount title
        Text(
          "CHOOSE AMOUNT",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),

        // Preset amounts row 1
        Row(
          children: [
            _buildLargeAmountButton(presetAmounts[0]),
            SizedBox(width: 10.w),
            _buildLargeAmountButton(presetAmounts[1]),
          ],
        ),
        SizedBox(height: 10.h),

        // Preset amounts row 2
        Row(
          children: [
            _buildLargeAmountButton(presetAmounts[2]),
            SizedBox(width: 10.w),
            _buildLargeAmountButton(presetAmounts[3]),
          ],
        ),
        SizedBox(height: 10.h),

        // Preset amounts row 3
        Row(
          children: [
            _buildLargeAmountButton(presetAmounts[4]),
            SizedBox(width: 10.w),
            _buildCustomAmountButton(),
          ],
        ),

        // Custom amount input field - only shown when custom amount is selected

        if (isCustomAmount) ...[
          SizedBox(height: 20.h),
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Ec_PRIMARY.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: TextFormField(
                controller: loadAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.w),
                  hintText: "Enter amount",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: Container(
                    margin: EdgeInsets.only(left: 16.w, right: 8.w),
                    child: Text(
                      "₱",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Ec_PRIMARY,
                      ),
                    ),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLargeAmountButton(int amount) {
    final bool isSelected = amount == selectedAmount;

    return Expanded(
      child: InkWell(
        onTap: () => _selectAmount(amount),
        child: Container(
          height: 70.h, // reduced height
          decoration: BoxDecoration(
            color: isSelected ? Ec_PRIMARY : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isSelected ? Ec_PRIMARY : Colors.grey[300]!,
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 10.sp, // slightly smaller check
                      color: Ec_PRIMARY,
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₱$amount",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 16.sp, // reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Ec_PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        "Standard",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Ec_PRIMARY,
                          fontSize: 10.sp, // reduced label size
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // Large amount selection button
  // Widget _buildLargeAmountButton(int amount) {
  //   final bool isSelected = amount == selectedAmount;

  //   return Expanded(
  //     child: InkWell(
  //       onTap: () => _selectAmount(amount),
  //       child: Container(
  //         height: 90.h,
  //         decoration: BoxDecoration(
  //           color: isSelected ? Ec_PRIMARY : Colors.white,
  //           borderRadius: BorderRadius.circular(12.r),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.05),
  //               blurRadius: 8,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //           border: Border.all(
  //             color: isSelected ? Ec_PRIMARY : Colors.grey[300]!,
  //             width: 1.5,
  //           ),
  //         ),
  //         child: Stack(
  //           children: [
  //             if (isSelected)
  //               Positioned(
  //                 top: 8.h,
  //                 right: 8.w,
  //                 child: Container(
  //                   padding: EdgeInsets.all(4.w),
  //                   decoration: const BoxDecoration(
  //                     color: Colors.white,
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: Icon(
  //                     Icons.check,
  //                     size: 12.sp,
  //                     color: Ec_PRIMARY,
  //                   ),
  //                 ),
  //               ),
  //             Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     "₱${amount}",
  //                     style: TextStyle(
  //                       color: isSelected ? Colors.white : Colors.black87,
  //                       fontSize: 20.sp,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   SizedBox(height: 6.h),
  //                   Container(
  //                     padding:
  //                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
  //                     decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? Colors.white.withOpacity(0.2)
  //                           : Ec_PRIMARY.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(20.r),
  //                     ),
  //                     child: Text(
  //                       "Standard",
  //                       style: TextStyle(
  //                         color: isSelected ? Colors.white : Ec_PRIMARY,
  //                         fontSize: 12.sp,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Custom amount selection button
  Widget _buildCustomAmountButton() {
    final bool isSelected = isCustomAmount;

    return Expanded(
      child: InkWell(
        onTap: () => _selectAmount(null),
        child: Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: isSelected ? Ec_PRIMARY : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isSelected ? Ec_PRIMARY : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 10.sp,
                      color: Ec_PRIMARY,
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 20.sp,
                      color: isSelected ? Colors.white : Ec_PRIMARY,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Ec_PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Custom",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Ec_PRIMARY,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ BuyLoadScreen build method called');
    try {
      print('🔧 Building Scaffold...');
      final scaffold = Scaffold(
        backgroundColor: Ec_BG_SKY_BLUE,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF013986),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Buy Load',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRFIDImage(context),
              SizedBox(height: 24.h),

              // Amount Selection Title
              Container(
                padding: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.payments_outlined,
                          color: Ec_PRIMARY, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Load Amount',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Amount selection buttons
              _buildPresetAmountButtons(),

              SizedBox(height: 30.h),

              // Payment Methods Title
              Container(
                padding: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.credit_card,
                          color: Ec_PRIMARY, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // QRPH Option
              _buildPaymentMethodButton(
                icon: Icons.qr_code,
                iconColor: Ec_PRIMARY,
                title: 'QR PH',
                subtitle: 'Scan with any banking app or e-wallet',
                isSelected: selectedPaymentMethod == 'QRPH',
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 'QRPH';
                  });
                },
              ),
              SizedBox(height: 12.h),

              // E-Wallet Option
              _buildPaymentMethodButton(
                icon: Icons.account_balance_wallet,
                iconColor: Colors.green,
                title: 'E-Wallet',
                subtitle: 'GCash, PayMaya, or other digital wallets',
                isSelected: selectedPaymentMethod == 'E-Wallet',
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 'E-Wallet';
                  });
                },
              ),

              // Help text
              if (selectedPaymentMethod == null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Please select a payment method to continue',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[600],
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Payment method selected: $selectedPaymentMethod',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 30.h),

              // Proceed to Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedPaymentMethod == null
                      ? null
                      : () => navigateToPaymentScreen(selectedPaymentMethod!),
                  icon:
                      Icon(Icons.payment, color: Ec_LIGHT_PRIMARY, size: 20.sp),
                  label: Text(
                    selectedPaymentMethod == null
                        ? 'Select Payment Method'
                        : 'Proceed to Payment',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Ec_WHITE),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPaymentMethod == null
                        ? Colors.grey[400]
                        : Ec_PRIMARY,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      print('✅ Scaffold built successfully');
      return scaffold;
    } catch (e, stackTrace) {
      print('❌ Error in BuyLoadScreen build: $e');
      print('❌ Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading Buy Load screen: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {}); // Try to rebuild
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Payment method button
  Widget _buildPaymentMethodButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? iconColor : iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? iconColor : Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? iconColor.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16.sp,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }

  // Helper method for confirmation dialog rows
  Widget _buildConfirmationRow(
      String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for success detail rows
  Widget _buildSuccessDetailRow(
      String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
