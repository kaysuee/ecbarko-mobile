import 'dart:math';
import 'package:EcBarko/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../screens/buyload_screen.dart';
import '../models/transaction_model.dart';

class RFIDCardScreen extends StatefulWidget {
  final bool showBackButton;

  const RFIDCardScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  State<RFIDCardScreen> createState() => _RFIDCardScreenState();
}

class _RFIDCardScreenState extends State<RFIDCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  List<Transaction> transactions = [
    Transaction(date: DateTime(2025, 5, 1), type: 'load', amount: 100),
    Transaction(date: DateTime(2025, 4, 30), type: 'use', amount: 20),
    Transaction(date: DateTime(2025, 4, 29), type: 'use', amount: 30),
    Transaction(date: DateTime(2025, 4, 28), type: 'load', amount: 200),
  ];

  String selectedFilterType = 'All';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  List<Transaction> get filteredTransactions {
    if (selectedFilterType == 'All') return transactions.reversed.toList();
    return transactions
        .where((t) => t.type.toLowerCase() == selectedFilterType.toLowerCase())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCardFront() {
    return Card(
      color: Ec_PRIMARY,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: _flipCard,
        child: Container(
          height: 210.h,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logoWhite.png',
                  width: 100.w,
                  height: 100.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Click the Logo to view the card details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    final expiryDate = DateTime.now().add(const Duration(days: 365 * 5));
    final expiryText = DateFormat('MM/yy').format(expiryDate);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _flipCard,
      child: Card(
        color: Ec_PRIMARY,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 6,
        child: Container(
          height: 210.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CARD NUMBER',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              SizedBox(height: 4.h),
              Text(
                '1234 5678 9012 3456',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 12.h),
              Text('VALID THRU',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              SizedBox(height: 4.h),
              Text(
                expiryText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'This card is the property of EcBarko. Please report lost or stolen cards to support@ecbarko.com',
                      style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Image.asset(
                    'assets/images/logoWhite.png',
                    width: 30.w,
                    height: 30.w,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFlip() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFront = _animation.value <= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _buildCardFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isLoad = transaction.type == 'load';
    final title =
        isLoad ? 'Purchased EcBarko RFID Load' : 'Payment for EcBarko RFID';
    final amount = '₱${transaction.amount.toStringAsFixed(2)}';
    final status = transaction.amount > 5000
        ? 'canceled'
        : transaction.amount >= 100
            ? 'confirmed'
            : 'pending';

    final statusColor = {
      'confirmed': Colors.green,
      'pending': Colors.orange,
      'canceled': Colors.red,
    }[status]!;

    return Container(
      // margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.credit_card, size: 20.sp, color: Colors.blue),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('dd MMM yyyy\nhh:mm a').format(transaction.date),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      body: SingleChildScrollView(
        // Add padding at the bottom to prevent navigation bar overlap
        padding: EdgeInsets.only(bottom: 80.h),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF013986),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(40.r)),
                  ),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'EcBarko',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28.sp,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: ' Card',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.showBackButton)
                  Positioned(
                    top: 20,
                    left: 10,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: -120.h,
                  child: _buildCardFlip(),
                ),
              ],
            ),
            SizedBox(height: 150.h),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BuyLoadScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r)),
                padding:
                    EdgeInsets.symmetric(horizontal: 150.w, vertical: 10.h),
              ),
              child: Text('Load',
                  style: TextStyle(fontSize: 20.sp, color: Colors.white)),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('History',
                          style: TextStyle(
                              fontSize: 24.sp, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Ec_DARK_PRIMARY),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFilterType,
                            items: ['All', 'Load', 'Use'].map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(fontSize: 14.sp)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFilterType = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Column(
                    children: filteredTransactions
                        .map(_buildTransactionItem)
                        .toList(),
                  ),
                ],
              ),
            ),
            // Add extra space at bottom for navigation bar
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
// import 'dart:math';
// import 'package:EcBarko/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../screens/buyload_screen.dart';
// import '../models/transaction_model.dart';

// class RFIDCardScreen extends StatefulWidget {
//   final bool showBackButton;

//   const RFIDCardScreen({Key? key, this.showBackButton = false})
//       : super(key: key);

//   @override
//   State<RFIDCardScreen> createState() => _RFIDCardScreenState();
// }

// class _RFIDCardScreenState extends State<RFIDCardScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool _isFront = true;

//   List<Transaction> transactions = [
//     Transaction(date: DateTime(2025, 5, 1), type: 'load', amount: 100),
//     Transaction(date: DateTime(2025, 4, 30), type: 'use', amount: 20),
//     Transaction(date: DateTime(2025, 4, 29), type: 'use', amount: 30),
//     Transaction(date: DateTime(2025, 4, 28), type: 'load', amount: 200),
//   ];

//   String selectedFilterType = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
//   }

//   void _flipCard() {
//     if (_isFront) {
//       _controller.forward();
//     } else {
//       _controller.reverse();
//     }
//     _isFront = !_isFront;
//   }

//   List<Transaction> get filteredTransactions {
//     if (selectedFilterType == 'All') return transactions.reversed.toList();
//     return transactions
//         .where((t) => t.type.toLowerCase() == selectedFilterType.toLowerCase())
//         .toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildCardFront() {
//     return Card(
//       color: Ec_PRIMARY,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       elevation: 6,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: _flipCard,
//         child: Container(
//           height: 210.h,
//           padding: const EdgeInsets.all(16),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/logoWhite.png',
//                   width: 100.w,
//                   height: 100.w,
//                 ),
//                 SizedBox(height: 5.h),
//                 Text(
//                   'Click the Logo to view the card details',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCardBack() {
//     final expiryDate = DateTime.now().add(const Duration(days: 365 * 5));
//     final expiryText = DateFormat('MM/yy').format(expiryDate);

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _flipCard,
//       child: Card(
//         color: Ec_PRIMARY,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         elevation: 6,
//         child: Container(
//           height: 210.h,
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('CARD NUMBER',
//                   style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
//               SizedBox(height: 4.h),
//               Text(
//                 '1234 5678 9012 3456',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//               SizedBox(height: 12.h),
//               Text('VALID THRU',
//                   style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
//               SizedBox(height: 4.h),
//               Text(
//                 expiryText,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     child: Text(
//                       'This card is the property of EcBarko. Please report lost or stolen cards to support@ecbarko.com',
//                       style: TextStyle(color: Colors.white70, fontSize: 10.sp),
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Image.asset(
//                     'assets/images/logoWhite.png',
//                     width: 30.w,
//                     height: 30.w,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCardFlip() {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _flipCard,
//       child: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) {
//           final angle = _animation.value * pi;
//           final isFront = _animation.value <= 0.5;

//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001)
//               ..rotateY(angle),
//             child: isFront
//                 ? _buildCardFront()
//                 : Transform(
//                     alignment: Alignment.center,
//                     transform: Matrix4.identity()..rotateY(pi),
//                     child: _buildCardBack(),
//                   ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTransactionItem(Transaction transaction) {
//     final isLoad = transaction.type == 'load';
//     final title =
//         isLoad ? 'Purchased EcBarko RFID Load' : 'Payment for EcBarko RFID';
//     final amount = '₱${transaction.amount.toStringAsFixed(2)}';
//     final status = transaction.amount > 5000
//         ? 'canceled'
//         : transaction.amount >= 100
//             ? 'confirmed'
//             : 'pending';

//     final statusColor = {
//       'confirmed': Colors.green,
//       'pending': Colors.orange,
//       'canceled': Colors.red,
//     }[status]!;

//     return Container(
//       // margin: EdgeInsets.only(bottom: 10.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         // borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40.w,
//             height: 40.w,
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Icon(Icons.credit_card, size: 20.sp, color: Colors.blue),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: TextStyle(
//                         fontSize: 14.sp, fontWeight: FontWeight.w600)),
//                 SizedBox(height: 4.h),
//                 Text(
//                   DateFormat('dd MMM yyyy\nhh:mm a').format(transaction.date),
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(amount,
//                   style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black)),
//               SizedBox(height: 4.h),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     color: statusColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Ec_BG_SKY_BLUE,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 200.h,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF013986),
//                     borderRadius:
//                         BorderRadius.vertical(bottom: Radius.circular(40.r)),
//                   ),
//                   child: Center(
//                     child: Text.rich(
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'EcBarko',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28.sp,
//                               fontStyle: FontStyle.italic,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           TextSpan(
//                             text: ' Card',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28.sp,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (widget.showBackButton)
//                   Positioned(
//                     top: 20,
//                     left: 10,
//                     child: SafeArea(
//                       child: IconButton(
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   left: 20.w,
//                   right: 20.w,
//                   bottom: -120.h,
//                   child: _buildCardFlip(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 150.h),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const BuyLoadScreen()));
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Ec_PRIMARY,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20.r)),
//                 padding:
//                     EdgeInsets.symmetric(horizontal: 150.w, vertical: 10.h),
//               ),
//               child: Text('Load',
//                   style: TextStyle(fontSize: 20.sp, color: Colors.white)),
//             ),
//             SizedBox(height: 20.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('History',
//                           style: TextStyle(
//                               fontSize: 24.sp, fontWeight: FontWeight.bold)),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           // borderRadius: BorderRadius.circular(8.r),
//                           border: Border.all(color: Ec_DARK_PRIMARY),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: selectedFilterType,
//                             items: ['All', 'Load', 'Use'].map((value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value,
//                                     style: TextStyle(fontSize: 14.sp)),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedFilterType = value!;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10.h),
//                   Column(
//                     children: filteredTransactions
//                         .map(_buildTransactionItem)
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10.h),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:math';
// import 'package:EcBarko/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../screens/buyload_screen.dart';
// import '../models/transaction_model.dart';

// class RFIDCardScreen extends StatefulWidget {
//   final bool showBackButton;

//   const RFIDCardScreen({Key? key, this.showBackButton = false})
//       : super(key: key);

//   @override
//   State<RFIDCardScreen> createState() => _RFIDCardScreenState();
// }

// class _RFIDCardScreenState extends State<RFIDCardScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool _isFront = true;

//   List<Transaction> transactions = [
//     Transaction(date: DateTime(2025, 5, 1), type: 'load', amount: 100),
//     Transaction(date: DateTime(2025, 4, 30), type: 'use', amount: 20),
//     Transaction(date: DateTime(2025, 4, 29), type: 'use', amount: 30),
//     Transaction(date: DateTime(2025, 4, 28), type: 'load', amount: 200),
//   ];

//   String selectedFilterType = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
//   }

//   void _flipCard() {
//     if (_isFront) {
//       _controller.forward();
//     } else {
//       _controller.reverse();
//     }
//     _isFront = !_isFront;
//   }

//   List<Transaction> get filteredTransactions {
//     if (selectedFilterType == 'All') return transactions.reversed.toList();
//     return transactions
//         .where((t) => t.type.toLowerCase() == selectedFilterType.toLowerCase())
//         .toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildCardFront() {
//     return Card(
//       color: Ec_PRIMARY,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       elevation: 6,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: _flipCard,
//         child: Container(
//           height: 210.h,
//           padding: EdgeInsets.all(16),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/logoWhite.png',
//                   width: 100.w,
//                   height: 100.w,
//                 ),
//                 SizedBox(height: 5.h),
//                 Text(
//                   'Click the Logo to view the card details',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCardBack() {
//     final expiryDate = DateTime.now().add(Duration(days: 365 * 5));
//     final expiryText = DateFormat('MM/yy').format(expiryDate);

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _flipCard,
//       child: Card(
//         color: Ec_PRIMARY,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         elevation: 6,
//         child: Container(
//           height: 210.h,
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('CARD NUMBER',
//                   style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
//               SizedBox(height: 4.h),
//               Text(
//                 '1234 5678 9012 3456',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//               SizedBox(height: 12.h),
//               Text('VALID THRU',
//                   style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
//               SizedBox(height: 4.h),
//               Text(
//                 expiryText,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     child: Text(
//                       'This card is the property of EcBarko. Please report lost or stolen cards to support@ecbarko.com',
//                       style: TextStyle(color: Colors.white70, fontSize: 10.sp),
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Image.asset(
//                     'assets/images/logoWhite.png',
//                     width: 30.w,
//                     height: 30.w,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCardFlip() {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _flipCard,
//       child: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) {
//           final angle = _animation.value * pi;
//           final isFront = _animation.value <= 0.5;

//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001)
//               ..rotateY(angle),
//             child: isFront
//                 ? _buildCardFront()
//                 : Transform(
//                     alignment: Alignment.center,
//                     transform: Matrix4.identity()..rotateY(pi),
//                     child: _buildCardBack(),
//                   ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTransactionItem(Transaction transaction) {
//     final isLoad = transaction.type == 'load';
//     final title =
//         isLoad ? 'Purchased EcBarko RFID Load' : 'Payment for EcBarko RFID';
//     final amount = '₱${transaction.amount.toStringAsFixed(2)}';
//     final status = transaction.amount > 5000
//         ? 'canceled'
//         : transaction.amount >= 100
//             ? 'confirmed'
//             : 'pending';

//     final statusColor = {
//       'confirmed': Colors.green,
//       'pending': Colors.orange,
//       'canceled': Colors.red,
//     }[status]!;

//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40.w,
//             height: 40.w,
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Icon(Icons.credit_card, size: 20.sp, color: Colors.blue),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: TextStyle(
//                         fontSize: 14.sp, fontWeight: FontWeight.w600)),
//                 SizedBox(height: 4.h),
//                 Text(
//                   DateFormat('dd MMM yyyy\nhh:mm a').format(transaction.date),
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(amount,
//                   style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black)),
//               SizedBox(height: 4.h),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     color: statusColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Ec_BG_SKY_BLUE,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 220.h,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF013986),
//                     borderRadius:
//                         BorderRadius.vertical(bottom: Radius.circular(40.r)),
//                   ),
//                   child: Center(
//                     child: Text.rich(
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'EcBarko',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28.sp,
//                               fontStyle: FontStyle.italic,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           TextSpan(
//                             text: ' Card',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28.sp,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (widget.showBackButton)
//                   Positioned(
//                     top: 20,
//                     left: 10,
//                     child: SafeArea(
//                       child: IconButton(
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   left: 20.w,
//                   right: 20.w,
//                   bottom: -120.h,
//                   child: _buildCardFlip(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 150.h),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const BuyLoadScreen()));
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Ec_PRIMARY,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20.r)),
//                 padding:
//                     EdgeInsets.symmetric(horizontal: 150.w, vertical: 10.h),
//               ),
//               child: Text('Load',
//                   style: TextStyle(fontSize: 20.sp, color: Colors.white)),
//             ),
//             SizedBox(height: 20.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('History',
//                           style: TextStyle(
//                               fontSize: 24.sp, fontWeight: FontWeight.bold)),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8.r),
//                           border: Border.all(color: Ec_DARK_PRIMARY),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: selectedFilterType,
//                             items: ['All', 'Load', 'Use'].map((value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value,
//                                     style: TextStyle(fontSize: 14.sp)),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedFilterType = value!;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10.h),
//                   Column(
//                     children: filteredTransactions
//                         .map(_buildTransactionItem)
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
