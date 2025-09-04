import 'dart:math';
import 'package:EcBarko/constants.dart';
import 'package:EcBarko/screens/linked_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../screens/buyload_screen.dart';
import '../screens/history_screen.dart';
import '../utils/date_format.dart';
import '../widgets/card_action_row.dart';

import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/notification_service.dart';

String formatCard(String cardNumber) {
  if (cardNumber.length != 12) return cardNumber;
  return '${cardNumber.substring(0, 4)}-${cardNumber.substring(4, 8)}-${cardNumber.substring(8)}';
}

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
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
      try {
        // Fetch card history (purchases/loads)
        final cardHistoryResponse = await http.get(
          Uri.parse('${getBaseUrl()}/api/cardHistory/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        // Fetch active bookings (card usage/payments)
        final bookingsResponse = await http.get(
          Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        List<Transaction> allTransactions = [];

        // Process card history (purchases)
        if (cardHistoryResponse.statusCode == 200) {
          final List<dynamic> cardHistoryList =
              jsonDecode(cardHistoryResponse.body);
          final cardTransactions = cardHistoryList
              .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
              .toList();
          allTransactions.addAll(cardTransactions);
        }

        // Process active bookings (card usage)
        if (bookingsResponse.statusCode == 200) {
          final List<dynamic> bookingsList = jsonDecode(bookingsResponse.body);
          final bookingTransactions = bookingsList
              .map((json) => _createTransactionFromBooking(json))
              .toList();
          allTransactions.addAll(bookingTransactions);
        }

        // Sort all transactions by date (newest first)
        allTransactions.sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          transactions = allTransactions;
        });
      } catch (e) {
        print('Error loading transaction history: $e');
      }
    }
  }

  Future<void> refreshCard() async {
    await _loadCard();
    await _loadCardHistory();
  }

  // Helper method to create Transaction from booking data
  Transaction _createTransactionFromBooking(Map<String, dynamic> booking) {
    // For "Use" transactions, we want to show when the payment was actually made
    // The API should provide the actual booking creation timestamp
    DateTime actualTransactionDate;

    // Debug: Print available fields to see what we can use
    print('Debug: Available booking fields: ${booking.keys.toList()}');

    // Try to find the actual transaction timestamp
    if (booking['createdAt'] != null) {
      try {
        actualTransactionDate = DateTime.parse(booking['createdAt']);
        print('Debug: Using createdAt: ${actualTransactionDate}');
      } catch (e) {
        print('Error parsing createdAt: $e');
        actualTransactionDate = DateTime.now();
      }
    } else if (booking['timestamp'] != null) {
      try {
        actualTransactionDate = DateTime.parse(booking['timestamp']);
        print('Debug: Using timestamp: ${actualTransactionDate}');
      } catch (e) {
        print('Error parsing timestamp: $e');
        actualTransactionDate = DateTime.now();
      }
    } else if (booking['dateTransaction'] != null) {
      // If no creation timestamp, use the dateTransaction but this might be departure date
      // We need to check if this is actually a creation timestamp
      try {
        actualTransactionDate = DateTime.parse(booking['dateTransaction']);
        print('Debug: Using dateTransaction: ${actualTransactionDate}');
        // Check if this looks like a departure date (future date) vs creation date (past date)
        if (actualTransactionDate.isAfter(DateTime.now())) {
          print(
              'Debug: dateTransaction appears to be a future departure date, using current time');
          actualTransactionDate = DateTime.now();
        }
      } catch (e) {
        print('Error parsing dateTransaction: $e');
        actualTransactionDate = DateTime.now();
      }
    } else {
      print('Debug: No timestamp field found, using current time');
      actualTransactionDate = DateTime.now();
    }

    // Convert to Philippine timezone (UTC+8)
    actualTransactionDate =
        actualTransactionDate.toUtc().add(const Duration(hours: 8));

    return Transaction(
      date: actualTransactionDate,
      type: 'Use', // Card usage
      amount: (booking['totalAmount'] ?? 0).toDouble(),
      status: booking['paymentStatus'] ?? 'Confirmed',
    );
  }

  Widget _buildCardFront() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 6,
      child: Container(
        height: screenHeight * 0.28, // Responsive height: 25% of screen height
        padding: EdgeInsets.all(
            screenWidth * 0.04), // Responsive padding: 4% of screen width
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
            // Responsive image with proper sizing
            SizedBox(
              width: screenWidth * 0.18, // Reduced from 0.25 to 0.18
              height: screenWidth * 0.18,
              child: Image.asset(
                'assets/images/ecbarkowhitelogo.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenHeight * 0.015), // Responsive spacing
            if (cardData != null && cardData!['cardNumber'] != null) ...[
              Text(
                cardData!['cardLabel'] ?? 'ECBARKO Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth *
                      0.045, // Responsive font size: 4.5% of screen width
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01), // Responsive spacing
              Text(
                'Tap to view card details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth *
                      0.035, // Responsive font size: 3.5% of screen width
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'No Card Linked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth *
                      0.045, // Responsive font size: 4.5% of screen width
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01), // Responsive spacing
              Text(
                'Tap to link your card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth *
                      0.035, // Responsive font size: 3.5% of screen width
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 6,
      child: Container(
        height: screenHeight * 0.28, // Responsive height: 25% of screen height
        padding: EdgeInsets.all(
            screenWidth * 0.04), // Responsive padding: 4% of screen width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      fontSize: screenWidth *
                          0.055, // Responsive font size: 5.5% of screen width
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (cardData != null && cardData!['cardLabel'] != null) ...[
                    SizedBox(
                        height: screenHeight * 0.005), // Responsive spacing
                    Text(
                      cardData!['cardLabel'],
                      style: TextStyle(
                        fontSize: screenWidth *
                            0.03, // Responsive font size: 3% of screen width
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.010), // Responsive spacing

            // Terms and conditions text
            Expanded(
              child: Text(
                'By using this card, the cardholder acknowledges that they have read and agreed '
                'to be bound by the Terms & Conditions of EcBarko. This card is non-transferable, '
                'and any tampering will render it invalid. If found, please return to the Philippine '
                'Ports Authority, Brgy. Talao-Talao, Port Area, Lucena City 4301, Philippines.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth *
                      0.025, // Responsive font size: 3.2% of screen width
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            SizedBox(height: screenHeight * 0.010), // Responsive spacing

            // Logos and contact info
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/ppalogo.png',
                  width: screenWidth *
                      0.12, // Responsive width: 12% of screen width
                  height: screenWidth * 0.12,
                ),
                SizedBox(width: screenWidth * 0.02), // Responsive spacing
                Image.asset(
                  'assets/images/logoWhite.png',
                  width: screenWidth *
                      0.12, // Responsive width: 12% of screen width
                  height: screenWidth * 0.12,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'For customer assistance, call',
                      style: TextStyle(
                        fontSize: screenWidth *
                            0.025, // Responsive font size: 2.5% of screen width
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '09614505935',
                      style: TextStyle(
                        fontSize: screenWidth *
                            0.025, // Responsive font size: 2.5% of screen width
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'or visit www.ecbarko.com',
                      style: TextStyle(
                        fontSize: screenWidth *
                            0.025, // Responsive font size: 2.5% of screen width
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
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
      appBar: AppBar(
        title: const Text(
          'RFID Card',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: refreshCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 80.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                child: _buildCardFlip(),
              ),
              SizedBox(
                  height: 10.h), // Reduced spacing between card and actions
              CardActionRow(
                onLoadTap: () => _navigateTo(context, const BuyLoadScreen()),
                onLinkCardTap: () =>
                    _navigateTo(context, const LinkedCardScreen()),
                onHistoryTap: () => _navigateTo(context, const HistoryScreen()),
              ),
              SizedBox(
                  height:
                      10.h), // Increased spacing between actions and history
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('History',
                        style: TextStyle(
                            fontSize: 24.sp, fontWeight: FontWeight.bold)),
                    SizedBox(
                        height: 20.h), // Increased spacing below history title
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length > 3
                          ? 3
                          : filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return _buildTransactionItem(transaction);
                      },
                    ),
                    if (filteredTransactions.length > 3) ...[
                      SizedBox(height: 16.h),
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              _navigateTo(context, const HistoryScreen()),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Ec_PRIMARY.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Ec_PRIMARY.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'View All ${filteredTransactions.length}',
                                    style: TextStyle(
                                      color: Ec_PRIMARY,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Ec_PRIMARY,
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
    final isLoad = transaction.type.toLowerCase() == 'load';
    final isUse = transaction.type.toLowerCase() == 'use';

    String title;
    if (isLoad) {
      title = 'Purchased EcBarko RFID Load';
    } else if (isUse) {
      title = 'Payment for EcBarko RFID';
    } else {
      title = 'EcBarko RFID Transaction';
    }

    final amount = '₱${transaction.amount.toStringAsFixed(2)}'.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');

    final status = transaction.status;

    final statusColor = {
          'Confirmed': Colors.green,
          'confirmed': Colors.green,
          'Pending': Colors.orange,
          'pending': Colors.orange,
          'Canceled': Colors.red,
          'canceled': Colors.red,
        }[status] ??
        Colors.grey;

    // Get appropriate icon and color based on transaction type
    IconData transactionIcon;
    Color iconColor;
    Color iconBgColor;

    if (isLoad) {
      transactionIcon = Icons.add_circle;
      iconColor = Colors.green;
      iconBgColor = Colors.green[50]!;
    } else if (isUse) {
      transactionIcon = Icons.payment;
      iconColor = Colors.blue;
      iconBgColor = Colors.blue[50]!;
    } else {
      transactionIcon = Icons.credit_card;
      iconColor = Colors.grey;
      iconBgColor = Colors.grey[50]!;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container with improved design
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                transactionIcon,
                size: 24.sp,
                color: iconColor,
              ),
            ),

            SizedBox(width: 12.w),

            // Main content with improved typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${DateFormatUtil.formatTransactionDate(transaction.date.toString())} ${DateFormatUtil.formatTimeFromDateTime(transaction.date)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount and status with improved layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
