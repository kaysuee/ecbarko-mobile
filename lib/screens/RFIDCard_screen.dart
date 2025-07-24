import 'dart:math';
import 'package:EcBarko/constants.dart';
import 'package:EcBarko/screens/linked_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../screens/buyload_screen.dart';
import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String formatCard(String cardNumber) {
  if (cardNumber.length != 12) return cardNumber;
  return '${cardNumber.substring(0, 4)}-${cardNumber.substring(4, 8)}-${cardNumber.substring(8)}';
}

String getBaseUrl() {
  return 'https://ecbarko.onrender.com';
  // return 'http://localhost:3000';
}

// Reusable flipping card widget
class FlippingCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlippingCard({Key? key, required this.front, required this.back})
      : super(key: key);

  @override
  State<FlippingCard> createState() => _FlippingCardState();
}

class _FlippingCardState extends State<FlippingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                  ? widget.front
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: widget.back,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// Main screen widget
class RFIDCardScreen extends StatefulWidget {
  final bool showBackButton;

  const RFIDCardScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  State<RFIDCardScreen> createState() => _RFIDCardScreenState();
}

class _RFIDCardScreenState extends State<RFIDCardScreen> {
  Map<String, dynamic>? cardData;
  List<Transaction> transactions = [];
  String selectedFilterType = 'All';

  List<Transaction> get filteredTransactions {
    if (selectedFilterType == 'All') return transactions.reversed.toList();
    return transactions
        .where((t) => t.type.toLowerCase() == selectedFilterType.toLowerCase())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void initState() {
    super.initState();
    _loadCard();
    _loadCardHistory();
  }

  Future<void> _loadCard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');
    final localCardNumber = prefs.getString('linkedCardNumber');
    final localCardLabel = prefs.getString('linkedCardLabel');

    // If we have local card data, use it immediately
    if (localCardNumber != null) {
      setState(() {
        cardData = {
          'cardNumber': localCardNumber,
          'cardLabel': localCardLabel ?? 'ECBARKO Card',
          'balance': '0.00', // Default balance if not available
          'status': 'Active',
        };
      });
    }

    // Then try to fetch remote data if we have credentials
    if (token != null && userId != null) {
      try {
        final response = await http.get(
          Uri.parse('${getBaseUrl()}/api/card/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final remoteData = jsonDecode(response.body);
          setState(() {
            cardData = {
              ...remoteData,
              'cardNumber': localCardNumber ?? remoteData['cardNumber'],
              'cardLabel':
                  localCardLabel ?? remoteData['cardLabel'] ?? 'ECBARKO Card',
            };
          });
        } else {
          print('Failed to load remote card data: ${response.statusCode}');
          // Keep using local data if remote fetch fails
        }
      } catch (e) {
        print('Error fetching remote card data: $e');
        // Keep using local data if there's an error
      }
    }
  }

  Future<void> _loadCardHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/cardHistory/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          transactions = jsonList
              .map((json) => Transaction.fromJson(json))
              .toList()
              .reversed
              .toList();
        });
      } else {
        print('Failed to load card history: ${response.statusCode}');
      }
    }
  }

  Future<void> refreshCard() async {
    await _loadCard();
    await _loadCardHistory();
  }

  Widget _buildCardFront() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 6,
      child: Container(
        height: 210.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF1A5A91),
              Color(0xFF142F60),
            ],
            stops: [0.3, 1.0],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ecbarkowhitelogo.png',
              width: 130.w,
              height: 130.w,
            ),
            SizedBox(height: 10.h),
            if (cardData != null && cardData!['cardNumber'] != null) ...[
              Text(
                cardData!['cardLabel'] ?? 'ECBARKO Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Tap to view card details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ] else ...[
              Text(
                'No Card Linked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Tap to link your card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 6,
      child: Container(
        height: 210.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Magnetic strip
            Container(
              height: 32.h,
              width: double.infinity,
              color: Colors.grey[850],
            ),
            SizedBox(height: 4.h),

            // Card Number (centered)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cardData != null && cardData!['cardNumber'] != null
                        ? formatCard(cardData!['cardNumber'])
                        : 'No card linked',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (cardData != null && cardData!['cardLabel'] != null) ...[
                    SizedBox(height: 0.h),
                    Text(
                      cardData!['cardLabel'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 0.h),

            // Terms and conditions text
            Text(
              'By using this card, the cardholder acknowledges that they have read and agreed '
              'to be bound by the Terms & Conditions of EcBarko. This card is non-transferable, '
              'and any tampering will render it invalid. If found, please return to the Philippine '
              'Ports Authority, Brgy. Talao-Talao, Port Area, Lucena City 4301, Philippines.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.justify,
            ),
            // const Spacer(),

            // Logos and contact info
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/ppalogo.png', // Make sure this exists
                  width: 36.w,
                  height: 36.w,
                ),
                SizedBox(width: 8.w),
                Image.asset(
                  'assets/images/logoWhite.png', // Consider using logoBlue.png for contrast
                  width: 36.w,
                  height: 36.w,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'For customer assistance, call',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '09614505935',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'or visit www.ecbarko.com',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFlip() {
    return FlippingCard(
      front: _buildCardFront(),
      back: _buildCardBack(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      body: RefreshIndicator(
        onRefresh: refreshCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 80.h),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 250.h,
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -120.h,
                    child: Container(
                      width: double.infinity,
                      margin:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: _buildCardFlip(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 120.h),
              _buildCardActionRow(context),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return _buildTransactionItem(transaction);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
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

  Widget _buildCardActionRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Ec_PRIMARY.withOpacity(0.15)),
      ),
      child: Row(
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
            icon: Icons.credit_card,
            label: 'Link Card',
            onTap: () => _navigateTo(context, const LinkedCardScreen()),
          ),
          // _buildCardActionButton(
          //   context,
          //   icon: Icons.history,
          //   label: 'History',
          //   onTap: () => _navigateTo(context, const HistoryScreen()),
          // ),
        ],
      ),
    );
  }

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
            Icon(icon, color: Ec_PRIMARY, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Ec_PRIMARY,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
