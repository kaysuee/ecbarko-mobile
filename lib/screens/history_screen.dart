import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:EcBarko/constants.dart';
import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    if (selectedFilterType == 'All') return transactions.reversed.toList();
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
              .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
              .toList()
              .reversed
              .toList();
        });
      } else {
        print('Failed to load card History data: ${response.statusCode}');
      }
    }
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isLoad = transaction.type == 'Load';
    final title =
        isLoad ? 'Purchased EcBarko RFID Load' : 'Payment for EcBarko RFID';
    final amount = '₱${transaction.amount.toStringAsFixed(2) ?? '0.00'}'
        .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');

    final status = transaction.status;

    final statusColor = {
      'Confirmed': Colors.green,
      'Pending': Colors.orange,
      'Canceled': Colors.red,
    }[status]!;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                      fontWeight: FontWeight.w600),
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
      body: Padding(
        padding: EdgeInsets.all(20.w),
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
                      items: ['All', 'Load', 'Use']
                          .map((value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(fontSize: 14.sp)),
                              ))
                          .toList(),
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
            Expanded(
              child: ListView(
                children:
                    filteredTransactions.map(_buildTransactionItem).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
