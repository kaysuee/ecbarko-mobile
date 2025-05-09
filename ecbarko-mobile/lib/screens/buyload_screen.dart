import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/about_screen.dart' as about_screen;
import 'package:EcBarko/screens/profile_screen.dart';
import 'package:EcBarko/widgets/bounce_tap_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Make sure screenutil is initialized in your app
import '../widgets/payment_card.dart';

import '../screens/history_screen.dart';

import 'package:EcBarko/constants.dart';

class BuyLoadScreen extends StatefulWidget {
  const BuyLoadScreen({super.key});

  @override
  State<BuyLoadScreen> createState() => _BuyLoadScreenState();
}

class _BuyLoadScreenState extends State<BuyLoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController loadAmountController = TextEditingController();
  bool isBalanceVisible = true;

  void navigateToPaymentScreen(String paymentMethod) {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentCard(
            amount: loadAmountController.text,
            paymentMethod: paymentMethod,
          ),
        ),
      );
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Widget _buildRFIDImage(BuildContext context) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(12),
  //       // onTap: () =>
  //       //     _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
  //       child: Card(
  //         color: Ec_PRIMARY,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         elevation: 6,
  //         child: Container(
  //           width: double.infinity,
  //           height: 210.h,
  //           padding: EdgeInsets.all(16.w),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     'Available Balance',
  //                     style: TextStyle(
  //                       color: Colors.white.withOpacity(0.9),
  //                       fontSize: 14.sp,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     icon: Icon(
  //                       isBalanceVisible
  //                           ? Icons.visibility
  //                           : Icons.visibility_off,
  //                       color: Colors.white,
  //                       size: 20.sp,
  //                     ),
  //                     onPressed: () {
  //                       setState(() {
  //                         isBalanceVisible = !isBalanceVisible;
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               Text(
  //                 isBalanceVisible ? '₱1,250.00' : '•••••••••',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 22.sp,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               Center(
  //                 child: Image.asset(
  //                   'assets/images/logoWhite.png',
  //                   width: 60.w,
  //                   height: 60.w,
  //                 ),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   TextButton.icon(
  //                     onPressed: () {
  //                       _navigateTo(context, const BuyLoadScreen());
  //                     },
  //                     icon: const Icon(Icons.attach_money, color: Colors.white),
  //                     label: const Text('Load',
  //                         style: TextStyle(color: Colors.white)),
  //                   ),
  //                   TextButton.icon(
  //                     onPressed: () {
  //                       _navigateTo(context, const HistoryScreen());
  //                     },
  //                     icon: const Icon(Icons.history, color: Colors.white),
  //                     label: const Text('History',
  //                         style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

// Improved RFID Card Widget
  Widget _buildRFIDImage(BuildContext context) {
    return BounceTapWrapper(
      onTap: () =>
          _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
      child: Card(
        color:
            Ec_PRIMARY, // Assuming this refers to the constant from 'constants.dart'
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 8,
        child: Container(
          width: double.infinity,
          height: 220.h,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Ec_PRIMARY, Ec_DARK_PRIMARY.withOpacity(0.8)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header with logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logoWhite.png',
                    width: 40.w,
                    height: 40.w,
                  ),
                  Text(
                    'RFID CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Balance section
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 4.h),

              // Balance amount with toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isBalanceVisible ? '₱1,250.00' : '•••••••••',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
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
                      size: 18.sp,
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCardActionButton(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'Load',
                    onTap: () => _navigateTo(context, const BuyLoadScreen()),
                  ),
                  _buildCardActionButton(
                    context,
                    icon: Icons.history,
                    label: 'History',
                    onTap: () => _navigateTo(context, const HistoryScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRFIDImage(context),
            const SizedBox(height: 20),
            const Text(
              'Enter desired load amount',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: loadAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '₱',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Payment Method(s)',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.blue),
                title: const Text('Debit/Credit Card'),
                subtitle: const Text('Pay with a card'),
                onTap: () => navigateToPaymentScreen("Credit Card"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Colors.green),
                title: const Text('E-Wallet'),
                subtitle: const Text('Use your preferred E-Wallet'),
                onTap: () => navigateToPaymentScreen("E-Wallet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../widgets/payment_card.dart';

// class BuyLoadScreen extends StatefulWidget {
//   const BuyLoadScreen({super.key});

//   @override
//   State<BuyLoadScreen> createState() => _BuyLoadScreenState();
// }

// class _BuyLoadScreenState extends State<BuyLoadScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController loadAmountController = TextEditingController();

//   void navigateToPaymentScreen(String paymentMethod) {
//     if (_formKey.currentState!.validate()) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentCard(
//             amount: loadAmountController.text,
//             paymentMethod: paymentMethod,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF013986),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Buy Load',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 350,
//                 height: 190,
//                 decoration: BoxDecoration(
//                   image: const DecorationImage(
//                     image: AssetImage('assets/images/dashboard-rfid.png'),
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               'Enter desired load amount',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 10),

//             Form(
//               key: _formKey,
//               child: TextFormField(
//                 controller: loadAmountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     child: Text(
//                       '₱',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
//                   hintText: '0.00',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an amount';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(height: 30),

//             const Text(
//               'Payment Method(s)',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 18,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 10),

//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.credit_card, color: Colors.blue),
//                 title: const Text('Debit/Credit Card'),
//                 subtitle: const Text('Pay with a card'),
//                 onTap: () => navigateToPaymentScreen("Credit Card"),
//               ),
//             ),
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
//                 title: const Text('E-Wallet'),
//                 subtitle: const Text('Use your preferred E-Wallet'),
//                 onTap: () => navigateToPaymentScreen("E-Wallet"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
