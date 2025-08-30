import 'package:EcBarko/screens/booking_screen.dart';
import 'package:EcBarko/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/date_format.dart';
import 'dart:math';

class BookingDetailsScreen extends StatefulWidget {
  final String schedcde;
  final String departureLocation;

  final String arrivalLocation;

  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final VoidCallback? onBookingCompleted; // Callback for booking completion

  const BookingDetailsScreen({
    super.key,
    required this.schedcde,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    this.onBookingCompleted,
  });

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final List<Map<String, TextEditingController>> passengers = [
    {
      "firstName": TextEditingController(),
      "lastName": TextEditingController(),
      "contact": TextEditingController()
    }
  ];

  final List<Map<String, TextEditingController>> vehicleDetails = [];

  final List<String> vehicleTypeOptions = [
    "Type 1 (1.0 - 3.0 LM)",
    "Type 2 (3.1 - 5.0 LM)",
    "Type 3 (5.1 - 7.0 LM)",
    "Type 4 (7.1 - 15.0 LM)",
  ];

  final List<String> carTypeOptions = [
    "🚗 Passenger Vehicles",
    "Sedan (3.0 LM)",
    "SUV (4.0 LM)",
    "Van (5.0 LM)",
    "Pickup Truck (4.5 LM)",
    "Mini Van (4.0 LM)",
    "Compact Car (3.0 LM)",
    "🚚 Commercial Vehicles",
    "Delivery Van (6.0 LM)",
    "Box Truck (8.0 LM)",
    "Refrigerated Truck (9.0 LM)",
    "Dump Truck (10.0 LM)",
    "Cargo Truck (8.0 LM)",
    "🚌 Public Transport",
    "Jeepney (4.0 LM)",
    "Mini Bus (7.0 LM)",
    "Tourist Bus (12.0 LM)",
    "School Bus (10.0 LM)",
    "🚛 Heavy Equipment",
    "Crane Truck (14.0 LM)",
    "Boom Truck (13.0 LM)",
    "Tanker Truck (15.0 LM)",
    "Container Truck (14.0 LM)",
    "Other (Not Listed)",
  ];

  bool hasVehicle = false;
  String? selectedCardType;
  late String bookingReference;

  // Validation state
  bool _isValidating = false;
  List<bool> _passengerValidationErrors = List.generate(3, (_) => false);
  List<bool> _vehicleValidationErrors = List.generate(4, (_) => false);

  @override
  void initState() {
    super.initState();
    bookingReference = _generateReference();
  }

  String _generateReference() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Validation methods
  void _validatePassenger(int passengerIndex) {
    if (!_isValidating) return;

    final passenger = passengers[passengerIndex];
    final firstName = passenger["firstName"]!.text.trim();
    final lastName = passenger["lastName"]!.text.trim();
    final contact = passenger["contact"]!.text.trim();

    setState(() {
      _passengerValidationErrors[0] = firstName.isEmpty;
      _passengerValidationErrors[1] = lastName.isEmpty;
      _passengerValidationErrors[2] = contact.isEmpty;
    });
  }

  void _validateVehicle(int vehicleIndex) {
    if (!_isValidating) return;

    final vehicle = vehicleDetails[vehicleIndex];
    final driverFirstName = vehicle['driverFirstName']!.text.trim();
    final driverLastName = vehicle['driverLastName']!.text.trim();
    final plateNumber = vehicle['plateNumber']!.text.trim();
    final vehicleType = vehicle['vehicleType']!.text.trim();

    setState(() {
      _vehicleValidationErrors[0] = driverFirstName.isEmpty;
      _vehicleValidationErrors[1] = driverLastName.isEmpty;
      _vehicleValidationErrors[2] = plateNumber.isEmpty;
      _vehicleValidationErrors[3] = vehicleType.isEmpty;
    });
  }

  bool _validateAllFields() {
    setState(() {
      _isValidating = true;
    });

    // Validate all passengers
    for (int i = 0; i < passengers.length; i++) {
      _validatePassenger(i);
    }

    // Validate all vehicles if applicable
    if (hasVehicle) {
      for (int i = 0; i < vehicleDetails.length; i++) {
        _validateVehicle(i);
      }
    }

    // Check if there are any validation errors
    bool hasPassengerErrors = _passengerValidationErrors.any((error) => error);
    bool hasVehicleErrors =
        hasVehicle && _vehicleValidationErrors.any((error) => error);

    return !hasPassengerErrors && !hasVehicleErrors;
  }

  void _clearValidationErrors() {
    setState(() {
      _isValidating = false;
      for (int i = 0; i < _passengerValidationErrors.length; i++) {
        _passengerValidationErrors[i] = false;
      }
      for (int i = 0; i < _vehicleValidationErrors.length; i++) {
        _vehicleValidationErrors[i] = false;
      }
    });
  }

  // Helper method to get the appropriate logo based on shipping line
  Widget _getLogoWidget() {
    if (widget.shippingLine.toLowerCase().contains('starhorse')) {
      return Image.asset(
        'assets/images/starhorselogo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_boat_filled,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          );
        },
      );
    } else if (widget.shippingLine.toLowerCase().contains('montenegro')) {
      return Image.asset(
        'assets/images/montenegrologo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_boat_filled,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          );
        },
      );
    }
    // Default logo for other shipping lines
    return Icon(
      Icons.directions_boat_filled,
      color: Colors.white.withOpacity(0.7),
      size: 24.sp,
    );
  }

  void addPassenger() {
    setState(() {
      passengers.add({
        "firstName": TextEditingController(),
        "lastName": TextEditingController(),
        "contact": TextEditingController(),
      });
    });
  }

  void removePassenger(int index) {
    setState(() {
      passengers.removeAt(index);
    });
  }

  void addNewVehicle() {
    setState(() {
      vehicleDetails.add({
        'plateNumber': TextEditingController(),
        'carType': TextEditingController(),
        'driverFirstName': TextEditingController(),
        'driverLastName': TextEditingController(),
        'customType': TextEditingController(),
        'vehicleType': TextEditingController(), // auto-filled card type
      });
    });
  }

  void removeVehicle(int index) {
    setState(() {
      vehicleDetails.removeAt(index);
    });
  }

  String getVehicleTypeFromLM(String carType) {
    final match = RegExp(r"(\d+(\.\d+)?)").firstMatch(carType);
    double lm = 0;
    if (match != null) {
      lm = double.tryParse(match.group(1)!) ?? 0;
    }

    if (lm <= 3.0) return "Type 1";
    if (lm <= 5.0) return "Type 2";
    if (lm <= 7.0) return "Type 3";
    return "Type 4";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Ec_PRIMARY,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 ENHANCED SCHEDULE CARD
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 🎫 Enhanced Header with Gradient Background
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Ec_PRIMARY,
                            Ec_PRIMARY.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Top row with schedule code and shipping line
                          Row(
                            children: [
                              // 🚢 Dynamic Logo with Background
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: SizedBox(
                                    width: 50.w,
                                    height: 50.h,
                                    child: _getLogoWidget(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.w),
                              // 📋 Schedule Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.shippingLine,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Schedule #${widget.schedcde}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 🎯 Booking Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'BOOKING',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // 🔵 LOCATIONS with enhanced design
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      widget.departureLocation,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 🚀 Arrow with enhanced styling
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      widget.arrivalLocation,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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

                    // 📅 Schedule Details Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔵 TIME INFO with enhanced layout - 2 rows
                          Column(
                            children: [
                              // Departure container
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_boat_filled,
                                      color: Ec_PRIMARY,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Departure',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        '${DateFormatUtil.formatDateAbbreviated(widget.departDate)} ${DateFormatUtil.formatTime(widget.departTime)}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Ec_PRIMARY,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // Arrival container
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.orange,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Arrival',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        '${DateFormatUtil.formatDateAbbreviated(widget.arriveDate)} ${DateFormatUtil.formatTime(widget.arriveTime)}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 📌 PASSENGER DETAILS FORM
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 Enhanced Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: Ec_PRIMARY,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Passenger Details",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Enter information for all passengers",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 📊 Passenger Counter Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${passengers.length}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // 🚀 Enhanced Passenger Cards
                  Column(
                    children: passengers.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, TextEditingController> passenger =
                          entry.value;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                index == 0 ? Colors.blue[50] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: index == 0
                                  ? Colors.blue[200]!
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 🎫 Passenger Header
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? Colors.blue[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(14.r),
                                    topRight: Radius.circular(14.r),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? Colors.blue[600]
                                            : Colors.grey[600],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            index == 0
                                                ? "Primary Passenger"
                                                : "Passenger ${index + 1}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: index == 0
                                                  ? Colors.blue[800]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            index == 0
                                                ? "Main booking holder"
                                                : "Additional passenger",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: index == 0
                                                  ? Colors.blue[600]
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // ❌ Remove Button (only for non-primary passengers)
                                    if (index > 0)
                                      GestureDetector(
                                        onTap: () => removePassenger(index),
                                        child: Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 18.sp,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // 📝 Passenger Form Fields
                              Container(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  children: [
                                    // First Name Field
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "First Name",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: passenger["firstName"],
                                          decoration: InputDecoration(
                                            hintText: "Enter first name",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Ec_PRIMARY,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              color: Colors.grey[500],
                                              size: 20.sp,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            _validatePassenger(index);
                                          },
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20.h),

                                    // Last Name Field
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Last Name",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: passenger["lastName"],
                                          decoration: InputDecoration(
                                            hintText: "Enter last name",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Ec_PRIMARY,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              color: Colors.grey[500],
                                              size: 20.sp,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            _validatePassenger(index);
                                          },
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20.h),

                                    // Contact Number Field
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Contact Number",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: passenger["contact"],
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            hintText: "e.g. 09123456789",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Ec_PRIMARY,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 14.h,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.phone_outlined,
                                              color: Colors.grey[500],
                                              size: 20.sp,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            _validatePassenger(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // ➕ Add Passenger Button
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: addPassenger,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[700],
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Colors.green[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 24.sp,
                      ),
                      label: Text(
                        "Add Another Passenger",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // 💡 Help Text
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
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
                            "All passengers must have valid identification documents for boarding. Primary passenger will receive booking confirmations.",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.blue[700],
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
            SizedBox(height: 20.h),
            // 📌 VEHICLE DETAILS FORM
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🚗 Enhanced Vehicle Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.directions_car_filled,
                          color: Colors.blue[600],
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vehicle Details",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Add vehicles you'll be bringing on board",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 🎛️ Vehicle Toggle Switch
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color:
                              hasVehicle ? Colors.green[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: hasVehicle
                                ? Colors.green[300]!
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasVehicle ? "Yes" : "No",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: hasVehicle
                                    ? Colors.green[700]
                                    : Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Switch.adaptive(
                              value: hasVehicle,
                              activeColor: Colors.green[600],
                              onChanged: (value) {
                                setState(() {
                                  hasVehicle = value;
                                  if (value && vehicleDetails.isEmpty) {
                                    addNewVehicle();
                                  } else if (!value) {
                                    vehicleDetails.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (hasVehicle) ...[
                    SizedBox(height: 20.h),

                    // 🚀 Enhanced Vehicle Cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehicleDetails.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicleDetails[index];

                        vehicle.putIfAbsent(
                            'customType', () => TextEditingController());
                        vehicle.putIfAbsent(
                            'vehicleType', () => TextEditingController());

                        return Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // 🎫 Vehicle Header
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14.r),
                                      topRight: Radius.circular(14.r),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.directions_car,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Vehicle ${index + 1}",
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[800],
                                              ),
                                            ),
                                            Text(
                                              "Vehicle and driver information",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.blue[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ❌ Remove Vehicle Button
                                      GestureDetector(
                                        onTap: () => removeVehicle(index),
                                        child: Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 18.sp,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 📝 Vehicle Form Fields
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    children: [
                                      // Driver's First Name Field
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Driver's First Name",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          TextField(
                                            controller:
                                                vehicle['driverFirstName'],
                                            decoration: InputDecoration(
                                              hintText: "Enter first name",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1.5,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[600]!,
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 14.h,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.person_outline,
                                                color: Colors.grey[500],
                                                size: 20.sp,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              _validateVehicle(index);
                                            },
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // Driver's Last Name Field
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Driver's Last Name",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          TextField(
                                            controller:
                                                vehicle['driverLastName'],
                                            decoration: InputDecoration(
                                              hintText: "Enter last name",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1.5,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[600]!,
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 14.h,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.person_outline,
                                                color: Colors.grey[500],
                                                size: 20.sp,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              _validateVehicle(index);
                                            },
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // Plate Number Field
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Plate Number",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          TextField(
                                            controller: vehicle['plateNumber'],
                                            decoration: InputDecoration(
                                              hintText: "e.g. ABC-1234",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1.5,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                borderSide: BorderSide(
                                                  color: Colors.blue[600]!,
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 14.h,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.confirmation_number,
                                                color: Colors.grey[500],
                                                size: 20.sp,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              _validateVehicle(index);
                                            },
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // Vehicle Type Dropdown
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Vehicle Type",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          DropdownSearch<String>(
                                            items: carTypeOptions,
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              fit: FlexFit.loose,
                                              constraints: const BoxConstraints(
                                                  maxHeight: 300),
                                              menuProps: const MenuProps(
                                                backgroundColor: Colors.white,
                                                elevation: 4,
                                              ),
                                              searchFieldProps:
                                                  const TextFieldProps(
                                                decoration: InputDecoration(
                                                  labelText:
                                                      "Search vehicle type",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              itemBuilder:
                                                  (context, item, isSelected) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 8.h,
                                                  ),
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? Colors.blue[600]
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            dropdownDecoratorProps:
                                                const DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                hintText: "Select vehicle type",
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                prefixIcon: Icon(
                                                    Icons.category_outlined),
                                              ),
                                            ),
                                            selectedItem:
                                                vehicle['vehicleType']!
                                                        .text
                                                        .isNotEmpty
                                                    ? vehicle['vehicleType']!
                                                        .text
                                                    : null,
                                            onChanged: (value) {
                                              setState(() {
                                                vehicle['vehicleType']!.text =
                                                    value!;
                                                if (value !=
                                                    "Other (Not Listed)") {
                                                  vehicle['customType']!
                                                      .clear();
                                                  // Auto-select card type based on LM
                                                  final match =
                                                      RegExp(r"(\d+(\.\d+)?)")
                                                          .firstMatch(value);
                                                  if (match != null) {
                                                    final lm = double.parse(
                                                        match.group(1)!);
                                                    if (lm <= 3.0) {
                                                      vehicle['carType']!.text =
                                                          "Type 1 (1.0 - 3.0 LM)";
                                                    } else if (lm <= 5.0) {
                                                      vehicle['carType']!.text =
                                                          "Type 2 (3.1 - 5.0 LM)";
                                                    } else if (lm <= 7.0) {
                                                      vehicle['carType']!.text =
                                                          "Type 3 (5.1 - 7.0 LM)";
                                                    } else {
                                                      vehicle['carType']!.text =
                                                          "Type 4 (7.1 - 15.0 LM)";
                                                    }
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      // Show custom type input if "Other"
                                      if (vehicle['vehicleType']!.text ==
                                          "Other (Not Listed)") ...[
                                        SizedBox(height: 20.h),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Specify Vehicle Type",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            TextField(
                                              controller: vehicle['customType'],
                                              decoration: InputDecoration(
                                                hintText:
                                                    "e.g. Boom Truck, Armored Vehicle",
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                  borderSide: BorderSide(
                                                    color: Colors.blue[600]!,
                                                    width: 2,
                                                  ),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 14.h,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.edit_note,
                                                  color: Colors.grey[500],
                                                  size: 20.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      SizedBox(height: 20.h),

                                      // Vehicle Card Type Dropdown
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Vehicle Card Type",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          DropdownSearch<String>(
                                            items: vehicleTypeOptions,
                                            popupProps: PopupProps.menu(
                                              showSearchBox: false,
                                              fit: FlexFit.loose,
                                              constraints: const BoxConstraints(
                                                  maxHeight: 200),
                                              menuProps: const MenuProps(
                                                backgroundColor: Colors.white,
                                                elevation: 4,
                                              ),
                                              itemBuilder:
                                                  (context, item, isSelected) {
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 8.h,
                                                  ),
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? Colors.blue[600]
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                hintText: "Select card type",
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                prefixIcon: Icon(
                                                    Icons.credit_card_outlined),
                                                suffixIcon:
                                                    vehicle['vehicleType']!
                                                                .text !=
                                                            "Other (Not Listed)"
                                                        ? Icon(Icons.lock,
                                                            color: Colors.grey)
                                                        : null,
                                              ),
                                            ),
                                            selectedItem: vehicle['carType']!
                                                    .text
                                                    .isNotEmpty
                                                ? vehicle['carType']!.text
                                                : null,
                                            enabled:
                                                vehicle['vehicleType']!.text ==
                                                    "Other (Not Listed)",
                                            onChanged: (value) {
                                              if (vehicle['vehicleType']!
                                                      .text ==
                                                  "Other (Not Listed)") {
                                                setState(() {
                                                  vehicle['carType']!.text =
                                                      value!;
                                                  selectedCardType = value;
                                                });
                                              }
                                            },
                                          ),
                                          SizedBox(height: 8.h),
                                          Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              border: Border.all(
                                                color: Colors.blue[200]!,
                                                width: 1,
                                              ),
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
                                                    "Card type is auto-detected based on vehicle size. Select manually only for custom vehicles.",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.blue[700],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // ➕ Add Another Vehicle Button
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: addNewVehicle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[700],
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(
                              color: Colors.blue[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 24.sp,
                        ),
                        label: Text(
                          "Add Another Vehicle",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // 💡 Vehicle Information
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[600],
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                "Vehicle Requirements",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _buildVehicleInfoRow(
                            Icons.security,
                            "Valid driver's license required",
                          ),
                          SizedBox(height: 8.h),
                          _buildVehicleInfoRow(
                            Icons.car_crash,
                            "Vehicle must be in good condition",
                          ),
                          SizedBox(height: 8.h),
                          _buildVehicleInfoRow(
                            Icons.schedule,
                            "Arrive 2 hours before departure",
                          ),
                          SizedBox(height: 8.h),
                          _buildVehicleInfoRow(
                            Icons.payment,
                            "Vehicle fees based on size (LM)",
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 🚫 No Vehicle Selected State
                  if (!hasVehicle) ...[
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "No Vehicle Selected",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Toggle the switch above to add vehicle details if you're bringing a vehicle on board.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 📌 Proceed Button
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                // Check if vehicle is required
                if (!hasVehicle) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 28.sp),
                          SizedBox(width: 10.w),
                          Text(
                            "Vehicle Required",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Please note that all passengers must have a vehicle to proceed with the booking.",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          SizedBox(height: 15.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Important:",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "• All passengers must have a vehicle\n• Vehicle details are required for booking\n• Please add vehicle details to proceed",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.orange[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // Use the new validation system
                if (!_validateAllFields()) {
                  // Show validation error dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 28.sp),
                          SizedBox(width: 10.w),
                          Text(
                            "Validation Error",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Please fill in all required fields marked with red indicators.",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          SizedBox(height: 15.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Required Fields:",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "• Passenger names and contact numbers\n• Vehicle driver details and plate number\n• Vehicle type selection",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.red[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 16.sp,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                if (hasVehicle && vehicleDetails.isNotEmpty) {
                  final selectedVehicle = vehicleDetails.first;
                  if (selectedVehicle['carType']!.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Missing Card Type"),
                        content: const Text(
                            "Please select a card type for your vehicle."),
                        actions: [
                          TextButton(
                            child: const Text("OK",
                                style: TextStyle(color: Ec_PRIMARY)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  selectedCardType = selectedVehicle['carType']!.text;
                }

                for (var i = 0; i < passengers.length; i++) {
                  final passenger = passengers[i];
                  if (passenger["firstName"]!.text.trim().isEmpty ||
                      passenger["lastName"]!.text.trim().isEmpty ||
                      passenger["contact"]!.text.trim().isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Missing Passenger Details"),
                        content: Text(
                            "Please fill out all fields for Passenger ${i + 1}."),
                        actions: [
                          TextButton(
                            child: const Text("OK",
                                style: TextStyle(color: Ec_PRIMARY)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                }

                if (hasVehicle) {
                  for (var i = 0; i < vehicleDetails.length; i++) {
                    final vehicle = vehicleDetails[i];
                    if (vehicle['driverFirstName']!.text.trim().isEmpty ||
                        vehicle['driverLastName']!.text.trim().isEmpty ||
                        vehicle['plateNumber']!.text.trim().isEmpty ||
                        vehicle['carType']!.text.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Incomplete Vehicle Details"),
                          content: Text(
                              "Please fill out all fields for Vehicle ${i + 1}."),
                          actions: [
                            TextButton(
                              child: const Text("OK",
                                  style: TextStyle(color: Ec_PRIMARY)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }
                }

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Ec_BG_SKY_BLUE,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.payment_outlined,
                            color: Ec_PRIMARY, size: 28.sp),
                        SizedBox(width: 10.w),
                        Text(
                          "Confirm Details",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Are you sure you want to proceed to payment?",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Please verify:",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "• All passenger details are complete\n• Vehicle details are accurate (if applicable)\n• Selected card type is correct",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_PRIMARY,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          "Yes, Proceed",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          if (hasVehicle && vehicleDetails.isNotEmpty) {
                            final selectedVehicle = vehicleDetails.first;
                            selectedCardType = selectedVehicle['carType']!.text;
                          }

                          // Check if payment has already been completed
                          final prefs = await SharedPreferences.getInstance();
                          final paymentKey = 'payment_$bookingReference';
                          final isAlreadyPaid =
                              prefs.getBool(paymentKey) ?? false;

                          if (isAlreadyPaid) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Payment Already Completed"),
                                content: const Text(
                                    "This booking has already been paid for. You cannot proceed to payment again."),
                                actions: [
                                  TextButton(
                                    child: const Text("OK",
                                        style: TextStyle(color: Ec_PRIMARY)),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                schedcde: widget.schedcde,
                                departureLocation: widget.departureLocation,
                                arrivalLocation: widget.arrivalLocation,
                                departDate: widget.departDate,
                                departTime: widget.departTime,
                                arriveDate: widget.arriveDate,
                                arriveTime: widget.arriveTime,
                                shippingLine: widget.shippingLine,
                                selectedCardType: selectedCardType!,
                                passengers: passengers
                                    .map((p) => {
                                          "name":
                                              "${p["firstName"]!.text} ${p["lastName"]!.text}",
                                          "contact": p["contact"]!.text,
                                        })
                                    .toList(),
                                hasVehicle: hasVehicle,
                                vehicleDetail: hasVehicle &&
                                        vehicleDetails.isNotEmpty
                                    ? vehicleDetails
                                        .map((v) => {
                                              "plateNumber":
                                                  v["plateNumber"]!.text,
                                              "carType":
                                                  v["vehicleType"]!.text ==
                                                          "Other (Not Listed)"
                                                      ? v["customType"]!.text
                                                      : v["vehicleType"]!.text,
                                              "vehicleOwner":
                                                  "${v["driverFirstName"]!.text} ${v["driverLastName"]!.text}"
                                            })
                                        .toList()
                                    : [],
                                bookingReference: bookingReference,
                                onPaymentCompleted: widget.onBookingCompleted,
                              ),
                            ),
                          ).then((_) {
                            // Show success message when returning from payment screen
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
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
                                        'Booking Successful!',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(15.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: Colors.blue[100]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    color: Colors.blue[700],
                                                    size: 20.sp),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'Booking Confirmation',
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
                                              'Your booking has been confirmed and an e-ticket has been generated.',
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
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Important Information',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            _buildInfoRow(
                                              Icons.access_time,
                                              'Arrive 1 hour before departure',
                                            ),
                                            SizedBox(height: 8.h),
                                            _buildInfoRow(
                                              Icons.credit_card,
                                              'Bring valid ID for verification',
                                            ),
                                            SizedBox(height: 8.h),
                                            _buildInfoRow(
                                              Icons.directions_boat,
                                              'Check-in at the port counter',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      Container(
                                        padding: EdgeInsets.all(15.w),
                                        decoration: BoxDecoration(
                                          color: Colors.amber[50],
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: Colors.amber[100]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.notifications_active,
                                                color: Colors.amber[700],
                                                size: 24.sp),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                'You will receive a confirmation email with your booking details.',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.amber[900],
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
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                      ),
                                      child: Text(
                                        'Go to Dashboard',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pushReplacementNamed(
                                            context, '/dashboard');
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Ec_PRIMARY,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: Text(
                                        'View Bookings',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BookingScreen(
                                              initialTab: 0,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Center(
                child: Text("Proceed to Payment",
                    style: TextStyle(fontSize: 18.sp, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
