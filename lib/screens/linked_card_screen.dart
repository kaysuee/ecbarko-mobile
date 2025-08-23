import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class LinkedCardScreen extends StatefulWidget {
  const LinkedCardScreen({super.key});

  @override
  State<LinkedCardScreen> createState() => _LinkedCardScreenState();
}

class _LinkedCardScreenState extends State<LinkedCardScreen> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardLabelController = TextEditingController();

  Future<void> _saveCard() async {
    final cardNumber = cardNumberController.text.trim();
    final cardLabel = cardLabelController.text.trim();
    final digitsOnly = cardNumber.replaceAll('-', '');

    if (digitsOnly.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Card number must contain exactly 12 digits.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('userID');
    final url = Uri.parse('${getBaseUrl()}/api/card/$cardNumber');
    final body = {
      'userId': user, // Needed if your schema requires it
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card saved successfully!')),
        );
        Navigator.pop(context);
      } else {
        print('Failed to save card: ${response.body}');
      }
    } catch (err) {
      print('Submit error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Link ECBARKO Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
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
                  Text(
                    'ECBARKO Card Number (last 12 digits)',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter card number (e.g. 1234-5678-9012)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
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
                  Text(
                    'Card Label (optional)',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: cardLabelController,
                    decoration: InputDecoration(
                      hintText: 'e.g. ECBarko',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Ec_PRIMARY,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: _saveCard,
                child: const Text(
                  'Save Card',
                  style: TextStyle(
                    fontSize: 16,
                    color: Ec_WHITE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:EcBarko/constants.dart';

// class LinkedCardScreen extends StatelessWidget {
//   const LinkedCardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController cardNumberController = TextEditingController();
//     final TextEditingController cardLabelController = TextEditingController();

//     return Scaffold(
//       backgroundColor: Ec_BG_SKY_BLUE,
//       appBar: AppBar(
//         title: const Text(
//           'Link ECBARKO Card',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Ec_PRIMARY,
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'ECBARKO Card Number (last 12 digits)',
//               style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 8.h),
//             TextField(
//               controller: cardNumberController,
//               keyboardType: TextInputType.number,
//               maxLength: 12,
//               decoration: InputDecoration(
//                 hintText: 'Enter card number',
//                 counterText: '',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 12.w,
//                   vertical: 12.h,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               'Card Label (optional)',
//               style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 8.h),
//             TextField(
//               controller: cardLabelController,
//               decoration: InputDecoration(
//                 hintText: 'e.g. ECBarko',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 12.w,
//                   vertical: 12.h,
//                 ),
//               ),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Ec_PRIMARY,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                 ),
//                 onPressed: () {
//                   // Save logic here (e.g. call API or save to prefs)
//                   final cardNumber = cardNumberController.text.trim();
//                   final cardLabel = cardLabelController.text.trim();

//                   if (cardNumber.length != 12) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('Card number must be 12 digits.')),
//                     );
//                     return;
//                   }

//                   // TODO: Save or navigate
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Card saved successfully!')),
//                   );
//                 },
//                 child: const Text(
//                   'Save Card',
//                   style: TextStyle(
//                       fontSize: 16,
//                       color: Ec_WHITE,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
