import 'package:EcBarko/screens/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:EcBarko/constants.dart';
import 'package:EcBarko/screens/ticket_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

String getBaseUrl() {
  return 'https://ecbarko.onrender.com';
  // return 'http://localhost:3000';
}

class PaymentScreen extends StatefulWidget {
  final String schedcde;
  final String departureLocation;
  final String arrivalLocation;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final String selectedCardType;
  final List<Map<String, String>> passengers;
  final bool hasVehicle;
  final List<Map<String, String>> vehicleDetail;
  final String bookingReference;

  PaymentScreen({
    super.key,
    required this.schedcde,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.selectedCardType,
    required this.passengers,
    required this.hasVehicle,
    required this.vehicleDetail,
    String? bookingReference,
  }) : bookingReference = _generateReference();

  static String _generateReference() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "EcBarko Card";
  double totalAmount = 0.0;
  List<double> passengerFares = [];
  double vehicleFare = 0.0;

  @override
  void initState() {
    super.initState();
    generateFixedFares();
  }

  Future<bool> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final user = prefs.getString('user');
    final url = Uri.parse('${getBaseUrl()}/api/eticket');

    final body = {
      "email": email,
      "user": user,
      "departureLocation": widget.departureLocation,
      "arrivalLocation": widget.arrivalLocation,
      "departDate": widget.departDate,
      "departTime": widget.departTime,
      "arriveDate": widget.arriveDate,
      "arriveTime": widget.arriveTime,
      "shippingLine": widget.shippingLine,
      "selectedCardType": widget.selectedCardType,
      "passengers": widget.passengers, // already formatted list of name/contact
      "hasVehicle": widget.hasVehicle,
      "vehicleDetail": widget.vehicleDetail,
      "bookingReference": widget.bookingReference,
      "totalFare": totalAmount,
      "schedcde": widget.schedcde,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (err) {
      print('Submit error: $err');

      return false;
    }
  }

  void generateFixedFares() {
    passengerFares = List.generate(widget.passengers.length, (_) => 500);
    if (widget.hasVehicle) {
      vehicleFare = 1000;
    }
    totalAmount =
        passengerFares.fold(0.0, (sum, fare) => sum + fare) + vehicleFare;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Ec_PRIMARY,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPaymentOption("EcBarko Card", Icons.credit_card),
                _buildPaymentOption("GCash", Icons.account_balance_wallet),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBookingSummaryCard()),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Amount",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(
                      "₱${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success =
                        await _submit(); // Wait for the API call to finish

                    if (!success) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Ec_BG_SKY_BLUE,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          title: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(15.w),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 40.sp,
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Text(
                                'Payment Successful!',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(15.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.blue[100]!,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.receipt_long,
                                            color: Colors.blue[700],
                                            size: 20.sp),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Booking Confirmed',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Your payment has been processed successfully.',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Container(
                                padding: EdgeInsets.all(15.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What would you like to do next?',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    _buildActionButton(
                                      context,
                                      Icons.dashboard,
                                      'Go to Dashboard',
                                      Colors.grey[600]!,
                                      () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      },
                                    ),
                                    SizedBox(height: 10.h),
                                    _buildActionButton(
                                      context,
                                      Icons.confirmation_number,
                                      'View E-Ticket',
                                      Ec_PRIMARY,
                                      () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TicketScreen(
                                              passengers: widget.passengers,
                                              departureLocation:
                                                  widget.departureLocation,
                                              arrivalLocation:
                                                  widget.arrivalLocation,
                                              departDate: widget.departDate,
                                              departTime: widget.departTime,
                                              arriveDate: widget.arriveDate,
                                              arriveTime: widget.arriveTime,
                                              shippingLine: widget.shippingLine,
                                              hasVehicle: widget.hasVehicle,
                                              bookingReference:
                                                  widget.bookingReference,
                                              selectedCardType:
                                                  widget.selectedCardType,
                                              vehicleDetail:
                                                  widget.vehicleDetail,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 10.h),
                                    _buildActionButton(
                                      context,
                                      Icons.book_online,
                                      'View Active Bookings',
                                      Ec_PRIMARY,
                                      () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BookingScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text("Pay Now",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Ec_DARK_PRIMARY,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = label;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selectedPaymentMethod == label
                ? Ec_PRIMARY
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: ListTile(
          leading: Icon(icon, color: Ec_PRIMARY),
          title:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Radio<String>(
            value: label,
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
              });
            },
            activeColor: Ec_PRIMARY,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_boat, color: Ec_PRIMARY),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${widget.departureLocation} ➝ ${widget.arrivalLocation}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.calendar_today,
                  "Depart: ${widget.departDate} at ${widget.departTime}"),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.event_available,
                  "Arrive: ${widget.arriveDate} at ${widget.arriveTime}"),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.local_shipping,
                  "Shipping Line: ${widget.shippingLine}"),
              const Divider(height: 30),
              const Text("👥 Passengers:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...List.generate(widget.passengers.length, (i) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Full Name: ${widget.passengers[i]["name"]}"),
                    Text("Contact Number: ${widget.passengers[i]["contact"]}"),
                    Text("Fare: ₱${passengerFares[i].toStringAsFixed(2)}"),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              if (widget.hasVehicle && widget.vehicleDetail.isNotEmpty) ...[
                const Divider(height: 30),
                const Text("🚗 Vehicle Details:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...List.generate(widget.vehicleDetail.length, (i) {
                  final vehicle = widget.vehicleDetail[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Driver Name: ${vehicle["vehicleOwner"] ?? "-"}"),
                      Text("Plate Number: ${vehicle["plateNumber"] ?? "-"}"),
                      Text("Car Type: ${vehicle["carType"] ?? "-"}"),
                      Text("Vehicle Fare: ₱${vehicleFare.toStringAsFixed(2)}"),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
