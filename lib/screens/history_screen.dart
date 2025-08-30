import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:EcBarko/constants.dart';
import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/date_format.dart';
import '../utils/date_format.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000'; // Change this to your actual base URL
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> transactions = [];

  String selectedFilterType = 'All';
  List<Transaction> get filteredTransactions {
    if (selectedFilterType == 'All') return transactions;
    return transactions
        .where((t) => t.type.toLowerCase() == selectedFilterType.toLowerCase())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void initState() {
    super.initState();
    _loadCardHistory();
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
          print(
              'Debug: Available card history fields: ${cardHistoryList.isNotEmpty ? cardHistoryList.first.keys.toList() : []}');
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

  // Method to handle refresh
  Future<void> _handleRefresh() async {
    await _loadCardHistory();
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

    final amount = '₱${transaction.amount.toStringAsFixed(2) ?? '0.00'}'
        .replaceAllMapped(
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
                      Flexible(
                        child: Text(
                          DateFormatUtil.formatTransactionDate(
                              transaction.date.toString()),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormatUtil.formatTimeFromDateTime(transaction.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: 20.w, vertical: 16.h), // padding for items only
          itemCount: filteredTransactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionItem(filteredTransactions[index]);
          },
        ),
      ),
    );
  }
}
