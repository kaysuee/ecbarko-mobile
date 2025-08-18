import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/about_screen.dart' as about_screen;
import 'package:EcBarko/screens/profile_screen.dart';
import 'package:EcBarko/widgets/bounce_tap_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/payment_card.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this package for QR code generation
import 'dart:math'; // For generating transaction IDs

import '../screens/history_screen.dart';

import 'package:EcBarko/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

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

  @override
  void initState() {
    super.initState();
    // Start with the first preset amount selected
    selectedAmount = presetAmounts[0];
    loadAmountController.text = selectedAmount.toString();
    _loadCard();
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("Buy Load Successful!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        print('Failed to buy load card: ${response.statusCode}');
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
    amountValue = double.parse(amount);

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
              // height: MediaQuery.of(context).size.height * 0.8,height: min(MediaQuery.of(context).size.height * 0.95, 700.h),
              height: min(MediaQuery.of(context).size.height * 0.90, 685.h),

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
                      size: 200.w,
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

                  const Spacer(),
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
                            _buyload();
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
          height: 220.h,
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logoWhite.png',
                    width: 60.w,
                    height: 60.w,
                  ),
                  Text(
                    'RFID CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
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
                      fontSize: 25.sp,
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
                      size: 25.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                isBalanceVisible == true
                    ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
                    : '•••••••••',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    return Scaffold(
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
                      fontSize: 18.sp,
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
                    child:
                        Icon(Icons.credit_card, color: Ec_PRIMARY, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.sp,
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
              onTap: () => navigateToPaymentScreen("QRPH"),
            ),
            SizedBox(height: 12.h),

            // E-Wallet Option
            _buildPaymentMethodButton(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.green,
              title: 'E-Wallet',
              subtitle: 'GCash, PayMaya, or other digital wallets',
              onTap: () => navigateToPaymentScreen("E-Wallet"),
            ),
            SizedBox(height: 30.h),

// Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => navigateToPaymentScreen(
                  "QRPH", // Default to QRPH or adjust logic to let user select preferred
                ),
                icon: Icon(Icons.payment, color: Ec_LIGHT_PRIMARY, size: 20.sp),
                label: Text(
                  'Proceed to Payment',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Ec_WHITE),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Ec_PRIMARY,
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
  }

  // Payment method button
  Widget _buildPaymentMethodButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
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
}
