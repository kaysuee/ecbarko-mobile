import 'package:EcBarko/screens/booking_screen.dart';
import 'package:EcBarko/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import 'package:dropdown_search/dropdown_search.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String schedcde;
  final String departureLocation;

  final String arrivalLocation;

  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;

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
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                color: Colors.white,
                elevation: 6,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,
                              color: Ec_PRIMARY, size: 20.w),
                          SizedBox(width: 6.w),
                          Text(
                            widget.departureLocation,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Ec_PRIMARY,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Icons.arrow_forward,
                              color: Colors.grey[600], size: 18.w),
                          SizedBox(width: 6.w),
                          Text(
                            widget.arrivalLocation,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Ec_PRIMARY,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Departure",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600])),
                              SizedBox(height: 4.h),
                              Text(widget.departDate,
                                  style: TextStyle(fontSize: 15.sp)),
                              Text(widget.departTime,
                                  style: TextStyle(fontSize: 15.sp)),
                            ],
                          ),
                          Icon(Icons.directions_boat_filled,
                              color: Ec_PRIMARY, size: 32.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Arrival",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600])),
                              SizedBox(height: 4.h),
                              // Text(widget.arriveDate,
                              //     style: TextStyle(fontSize: 15.sp)),
                              Text(widget.arriveTime,
                                  style: TextStyle(fontSize: 15.sp)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_boat_filled,
                              color: Colors.grey[600], size: 18.w),
                          SizedBox(width: 8.w),
                          Text(
                            widget.shippingLine,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 📌 PASSENGER DETAILS FORM
            Text("Passenger Details",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),

            Column(
              children: passengers.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> passenger = entry.value;

                return Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Ec_WHITE,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Passenger ${index + 1}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: passenger["firstName"],
                                    decoration: InputDecoration(
                                      labelText: "First Name",
                                      hintText: "Enter first name",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    controller: passenger["lastName"],
                                    decoration: InputDecoration(
                                      labelText: "Last Name",
                                      hintText: "Enter last name",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: passenger["contact"],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Contact Number",
                                hintText: "e.g. 09123456789",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => removeVehicle(index),
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[100],
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: addPassenger,
                icon:
                    const Icon(Icons.add_circle_outline, color: Colors.black87),
                label: Text("Add Passenger",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            SizedBox(height: 20.h),
            // 📌 VEHICLE DETAILS FORM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Bringing a Vehicle?",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                Switch.adaptive(
                  value: hasVehicle,
                  activeColor: Ec_DARK_PRIMARY,

                  // activeColor: Colors.black87,
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

            if (hasVehicle) ...[
              SizedBox(height: 10.h),
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
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            // color: Colors.grey[100],
                            color: Ec_WHITE,

                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Vehicle ${index + 1}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp)),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: vehicle['driverFirstName'],
                                      decoration: InputDecoration(
                                        labelText: "Driver's First Name",
                                        hintText: "Enter first name",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: TextField(
                                      controller: vehicle['driverLastName'],
                                      decoration: InputDecoration(
                                        labelText: "Driver's Last Name",
                                        hintText: "Enter last name",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              TextField(
                                controller: vehicle['plateNumber'],
                                decoration: InputDecoration(
                                  labelText: "Plate Number",
                                  hintText: "e.g. ABC-1234",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // ✅ VEHICLE TYPE DROPDOWN
                              DropdownSearch<String>(
                                items: carTypeOptions,
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  fit: FlexFit.loose,
                                  constraints:
                                      const BoxConstraints(maxHeight: 300),
                                  menuProps: const MenuProps(
                                    backgroundColor: Colors.white,
                                    elevation: 4,
                                  ),
                                  searchFieldProps: const TextFieldProps(
                                    decoration: InputDecoration(
                                      labelText: "Search vehicle type",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  itemBuilder: (context, item, isSelected) {
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
                                              ? Ec_PRIMARY
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                dropdownDecoratorProps:
                                    const DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Vehicle Type",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                selectedItem:
                                    vehicle['vehicleType']!.text.isNotEmpty
                                        ? vehicle['vehicleType']!.text
                                        : null,
                                onChanged: (value) {
                                  setState(() {
                                    vehicle['vehicleType']!.text = value!;
                                    if (value != "Other (Not Listed)") {
                                      vehicle['customType']!.clear();
                                      // Auto-select card type based on LM
                                      final match = RegExp(r"(\d+(\.\d+)?)")
                                          .firstMatch(value);
                                      if (match != null) {
                                        final lm =
                                            double.parse(match.group(1)!);
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
                              SizedBox(height: 12.h),

                              // ✅ Show custom type input if "Other"
                              if (vehicle['vehicleType']!.text ==
                                  "Other (Not Listed)")
                                TextField(
                                  controller: vehicle['customType'],
                                  decoration: InputDecoration(
                                    labelText: "Specify Vehicle Type",
                                    hintText:
                                        "e.g. Boom Truck, Armored Vehicle",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),

                              SizedBox(height: 12.h),

                              // ✅ Show auto-filled vehicle type with dropdown capability
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownSearch<String>(
                                    items: vehicleTypeOptions,
                                    popupProps: PopupProps.menu(
                                      showSearchBox: false,
                                      fit: FlexFit.loose,
                                      constraints:
                                          const BoxConstraints(maxHeight: 200),
                                      menuProps: const MenuProps(
                                        backgroundColor: Colors.white,
                                        elevation: 4,
                                      ),
                                      itemBuilder: (context, item, isSelected) {
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
                                                  ? Ec_PRIMARY
                                                  : Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Vehicle Card Type",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                        suffixIcon:
                                            vehicle['vehicleType']!.text !=
                                                    "Other (Not Listed)"
                                                ? const Icon(Icons.lock,
                                                    color: Colors.grey)
                                                : null,
                                      ),
                                    ),
                                    selectedItem:
                                        vehicle['carType']!.text.isNotEmpty
                                            ? vehicle['carType']!.text
                                            : null,
                                    enabled: vehicle['vehicleType']!.text ==
                                        "Other (Not Listed)",
                                    onChanged: (value) {
                                      if (vehicle['vehicleType']!.text ==
                                          "Other (Not Listed)") {
                                        setState(() {
                                          vehicle['carType']!.text = value!;
                                          selectedCardType = value;
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(height: 8.h),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Text(
                                      "Note: Select card type based on vehicle size. This should match the auto-detected vehicle type.",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ❌ Remove Vehicle Button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => removeVehicle(index),
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red[100],
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: addNewVehicle,
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.black87),
                  label: Text(
                    "Add Another Vehicle",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

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
                        onPressed: () {
                          if (hasVehicle && vehicleDetails.isNotEmpty) {
                            final selectedVehicle = vehicleDetails.first;
                            selectedCardType = selectedVehicle['carType']!.text;
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
}
