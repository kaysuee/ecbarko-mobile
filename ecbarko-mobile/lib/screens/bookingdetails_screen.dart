import 'package:EcBarko/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String departureLocation;
  final String departurePort;
  final String arrivalLocation;
  final String arrivalPort;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;

  const BookingDetailsScreen({
    super.key,
    required this.departureLocation,
    required this.departurePort,
    required this.arrivalLocation,
    required this.arrivalPort,
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
  String? selectedCardType;
  final List<String> cardTypes = ["Type 1", "Type 2", "Type 3", "Type 4"];

  List<Map<String, TextEditingController>> passengers = [
    {"name": TextEditingController(), "contact": TextEditingController()}
  ];

  List<Map<String, TextEditingController>> vehicleDetails = [];

  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController carTypeController = TextEditingController();
  final TextEditingController vehicleOwnerController = TextEditingController();

  bool hasVehicle = false;

  void addPassenger() {
    setState(() {
      passengers.add({
        "name": TextEditingController(),
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
      // Add a new map for each new vehicle
      vehicleDetails.add({
        'plateNumber': TextEditingController(),
        'carType': TextEditingController(),
        'vehicleOwner': TextEditingController(),
      });
    });
  }

  void removeVehicle(int index) {
    setState(() {
      vehicleDetails.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // 📌 ENHANCED SCHEDULE CARD (CENTERED CONTENT)
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                color: Colors.white,
                elevation: 6,
                shadowColor: Colors.black12,
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
                            '${widget.departureLocation}',
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
                            '${widget.arrivalLocation}',
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
                              Text(
                                '${widget.departDate}',
                                style: TextStyle(fontSize: 15.sp),
                              ),
                              Text(
                                widget.departTime,
                                style: TextStyle(fontSize: 15.sp),
                              ),
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
                              Text(
                                '${widget.arriveDate}',
                                style: TextStyle(fontSize: 15.sp),
                              ),
                              Text(
                                widget.arriveTime,
                                style: TextStyle(fontSize: 15.sp),
                              ),
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
                          Icon(Icons.local_shipping,
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

            // 📌 CARD TYPE SELECTION
            Text("Card Type",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: selectedCardType,
              hint: Text("Select a Card Type"),
              items: cardTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCardType = value;
                });
              },
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Ec_PRIMARY, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                filled: true,
                fillColor: Colors.grey[100],
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
                          color: Colors.grey[100], // ✅ Neutral background
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                              color: Colors.grey.shade300), // ✅ Neutral border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05), // ✅ Neutral shadow
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
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
                                  color: Colors.black, // ✅ Changed from blue
                                )),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: passenger["name"],
                              decoration: InputDecoration(
                                labelText: "Full Name",
                                hintText: "Enter full name",
                                labelStyle: TextStyle(color: Colors.black87),
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: passenger["contact"],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Contact Number",
                                hintText: "e.g. 09123456789",
                                labelStyle: TextStyle(color: Colors.black87),
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ❌ Remove Button (Simplified - No Circular Background)
                      Positioned(
                        top:
                            12, // Adjusted the position to move it away from the top edge
                        right:
                            12, // Adjusted the position to move it away from the right edge
                        child: GestureDetector(
                          onTap: () => removePassenger(index),
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[100],
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 22, // Increased size for boldness
                              color: Colors.red, // Kept the bold red color
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // 📌 ADD PASSENGER BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: addPassenger,
                icon: Icon(Icons.add_circle_outline,
                    color: Colors.black87), // ✅ Changed from blue
                label: Text("Add Passenger",
                    style: TextStyle(
                      color: Colors.black87, // ✅ Changed from blue
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            SizedBox(height: 20.h),

            // 📌 VEHICLE DETAILS FORM (OPTIONAL)
            // 📌 SWITCH OUTSIDE CONTAINER
            // 📌 BRINGING A VEHICLE SWITCH (OUTSIDE)
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
                  activeColor: Colors.black87,
                  onChanged: (value) {
                    setState(() {
                      hasVehicle = value;
                      if (value && vehicleDetails.isEmpty) {
                        addNewVehicle(); // ✅ Add first vehicle form
                      } else if (!value) {
                        vehicleDetails
                            .clear(); // ✅ Clear all forms if toggled off
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
                physics: NeverScrollableScrollPhysics(),
                itemCount: vehicleDetails.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicleDetails[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: Offset(0, 3),
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
                              TextField(
                                controller: vehicle['vehicleOwner'],
                                decoration: InputDecoration(
                                  labelText: "Vehicle Owner",
                                  hintText: "Enter owner's name",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              TextField(
                                controller: vehicle['plateNumber'],
                                decoration: InputDecoration(
                                  labelText: "Plate Number",
                                  hintText: "e.g. ABC-1234",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              TextField(
                                controller: vehicle['carType'],
                                decoration: InputDecoration(
                                  labelText: "Car Type",
                                  hintText: "e.g. SUV, Sedan, Truck",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],
                          ),
                        ),
                        // ❌ Positioned Remove Button
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
                              child: Icon(
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

              // 📌 Add Another Vehicle Button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: addNewVehicle,
                  icon: Icon(Icons.add_circle_outline, color: Colors.black87),
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

            ElevatedButton(
              onPressed: () {
                // Validate card type
                if (selectedCardType == null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Missing Information"),
                      content:
                          Text("Please select a card type before proceeding."),
                      actions: [
                        TextButton(
                          child:
                              Text("OK", style: TextStyle(color: Ec_PRIMARY)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // Validate passengers
                for (var i = 0; i < passengers.length; i++) {
                  final passenger = passengers[i];
                  if (passenger["name"]!.text.trim().isEmpty ||
                      passenger["contact"]!.text.trim().isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Missing Passenger Details"),
                        content: Text(
                            "Please fill out all fields for Passenger ${i + 1}."),
                        actions: [
                          TextButton(
                            child:
                                Text("OK", style: TextStyle(color: Ec_PRIMARY)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                }

                // Validate vehicle fields if applicable
                if (hasVehicle) {
                  for (var i = 0; i < vehicleDetails.length; i++) {
                    final vehicle = vehicleDetails[i];
                    if (vehicle['vehicleOwner']!.text.trim().isEmpty ||
                        vehicle['plateNumber']!.text.trim().isEmpty ||
                        vehicle['carType']!.text.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Incomplete Vehicle Details"),
                          content: Text(
                              "Please fill out all fields for Vehicle ${i + 1}."),
                          actions: [
                            TextButton(
                              child: Text("OK",
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

                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Confirm Details"),
                    content:
                        Text("Are you sure you want to proceed to payment?"),
                    actions: [
                      TextButton(
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.grey)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_PRIMARY,
                        ),
                        child: Text("Yes, Proceed",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
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
                                          "name": p["name"]!.text,
                                          "contact": p["contact"]!.text
                                        })
                                    .toList(),
                                hasVehicle: hasVehicle,
                                plateNumber: plateNumberController.text,
                                carType: carTypeController.text,
                              ),
                            ),
                          );
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
}

// import 'package:EcBarko/screens/payment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../constants.dart';

// class BookingDetailsScreen extends StatefulWidget {
//   final String departureLocation;
//   final String departurePort;
//   final String arrivalLocation;
//   final String arrivalPort;
//   final String departDate;
//   final String departTime;
//   final String arriveDate;
//   final String arriveTime;
//   final String shippingLine;

//   const BookingDetailsScreen({
//     super.key,
//     required this.departureLocation,
//     required this.departurePort,
//     required this.arrivalLocation,
//     required this.arrivalPort,
//     required this.departDate,
//     required this.departTime,
//     required this.arriveDate,
//     required this.arriveTime,
//     required this.shippingLine,
//   });

//   @override
//   _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
// }

// class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
//   String? selectedCardType;
//   final List<String> cardTypes = ["Type 1", "Type 2", "Type 3", "Type 4"];

//   List<Map<String, TextEditingController>> passengers = [
//     {"name": TextEditingController(), "contact": TextEditingController()}
//   ];

//   List<Map<String, TextEditingController>> vehicleDetails = [];

//   final TextEditingController plateNumberController = TextEditingController();
//   final TextEditingController carTypeController = TextEditingController();
//   final TextEditingController vehicleOwnerController = TextEditingController();

//   bool hasVehicle = false;

//   void addPassenger() {
//     setState(() {
//       passengers.add({
//         "name": TextEditingController(),
//         "contact": TextEditingController(),
//       });
//     });
//   }

//   void removePassenger(int index) {
//     setState(() {
//       passengers.removeAt(index);
//     });
//   }

//   void addNewVehicle() {
//     setState(() {
//       // Add a new map for each new vehicle
//       vehicleDetails.add({
//         'plateNumber': TextEditingController(),
//         'carType': TextEditingController(),
//         'vehicleOwner': TextEditingController(),
//       });
//     });
//   }

//   void removeVehicle(int index) {
//     setState(() {
//       vehicleDetails.removeAt(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           'Booking Details',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: Ec_PRIMARY,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 📌 ENHANCED SCHEDULE CARD (CENTERED CONTENT)
//             SizedBox(
//               width: double.infinity,
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 color: Colors.white,
//                 elevation: 6,
//                 shadowColor: Colors.black12,
//                 child: Padding(
//                   padding: EdgeInsets.all(20.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.location_on,
//                               color: Ec_PRIMARY, size: 20.w),
//                           SizedBox(width: 6.w),
//                           Text(
//                             '${widget.departureLocation}',
//                             style: TextStyle(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Ec_PRIMARY,
//                             ),
//                           ),
//                           SizedBox(width: 6.w),
//                           Icon(Icons.arrow_forward,
//                               color: Colors.grey[600], size: 18.w),
//                           SizedBox(width: 6.w),
//                           Text(
//                             '${widget.arrivalLocation}',
//                             style: TextStyle(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Ec_PRIMARY,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 14.h),
//                       Divider(thickness: 1, color: Colors.grey[300]),
//                       SizedBox(height: 12.h),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text("Departure",
//                                   style: TextStyle(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey[600])),
//                               SizedBox(height: 4.h),
//                               Text(
//                                 '${widget.departDate}',
//                                 style: TextStyle(fontSize: 15.sp),
//                               ),
//                               Text(
//                                 widget.departTime,
//                                 style: TextStyle(fontSize: 15.sp),
//                               ),
//                             ],
//                           ),
//                           Icon(Icons.directions_boat_filled,
//                               color: Ec_PRIMARY, size: 32.w),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text("Arrival",
//                                   style: TextStyle(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey[600])),
//                               SizedBox(height: 4.h),
//                               Text(
//                                 '${widget.arriveDate}',
//                                 style: TextStyle(fontSize: 15.sp),
//                               ),
//                               Text(
//                                 widget.arriveTime,
//                                 style: TextStyle(fontSize: 15.sp),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16.h),
//                       Divider(thickness: 1, color: Colors.grey[300]),
//                       SizedBox(height: 12.h),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.local_shipping,
//                               color: Colors.grey[600], size: 18.w),
//                           SizedBox(width: 8.w),
//                           Text(
//                             widget.shippingLine,
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20.h),

//             // 📌 CARD TYPE SELECTION
//             Text("Card Type",
//                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8.h),
//             DropdownButtonFormField<String>(
//               value: selectedCardType,
//               hint: Text("Select a Card Type"),
//               items: cardTypes.map((String type) {
//                 return DropdownMenuItem<String>(
//                   value: type,
//                   child: Text(type),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedCardType = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide(color: Ec_PRIMARY, width: 1.2),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide(color: Colors.grey.shade400),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // 📌 PASSENGER DETAILS FORM
//             Text("Passenger Details",
//                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10.h),

//             Column(
//               children: passengers.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 Map<String, TextEditingController> passenger = entry.value;

//                 return Padding(
//                   padding: EdgeInsets.only(bottom: 15.h),
//                   child: Stack(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(16.w),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100], // ✅ Neutral background
//                           borderRadius: BorderRadius.circular(16.r),
//                           border: Border.all(
//                               color: Colors.grey.shade300), // ✅ Neutral border
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black
//                                   .withOpacity(0.05), // ✅ Neutral shadow
//                               blurRadius: 6,
//                               spreadRadius: 1,
//                               offset: Offset(0, 3),
//                             )
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Passenger ${index + 1}",
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black, // ✅ Changed from blue
//                                 )),
//                             SizedBox(height: 8.h),
//                             TextField(
//                               controller: passenger["name"],
//                               decoration: InputDecoration(
//                                 labelText: "Full Name",
//                                 hintText: "Enter full name",
//                                 labelStyle: TextStyle(color: Colors.black87),
//                                 hintStyle: TextStyle(color: Colors.grey),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 12.h),
//                             TextField(
//                               controller: passenger["contact"],
//                               keyboardType: TextInputType.phone,
//                               decoration: InputDecoration(
//                                 labelText: "Contact Number",
//                                 hintText: "e.g. 09123456789",
//                                 labelStyle: TextStyle(color: Colors.black87),
//                                 hintStyle: TextStyle(color: Colors.grey),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // ❌ Remove Button (Simplified - No Circular Background)
//                       Positioned(
//                         top:
//                             12, // Adjusted the position to move it away from the top edge
//                         right:
//                             12, // Adjusted the position to move it away from the right edge
//                         child: GestureDetector(
//                           onTap: () => removePassenger(index),
//                           child: Container(
//                             width: 20.w,
//                             height: 20.w,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.red[100],
//                               border: Border.all(color: Colors.redAccent),
//                             ),
//                             child: Icon(
//                               Icons.close,
//                               size: 22, // Increased size for boldness
//                               color: Colors.red, // Kept the bold red color
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),

//             // 📌 ADD PASSENGER BUTTON
//             Align(
//               alignment: Alignment.centerLeft,
//               child: TextButton.icon(
//                 onPressed: addPassenger,
//                 icon: Icon(Icons.add_circle_outline,
//                     color: Colors.black87), // ✅ Changed from blue
//                 label: Text("Add Passenger",
//                     style: TextStyle(
//                       color: Colors.black87, // ✅ Changed from blue
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                     )),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // 📌 VEHICLE DETAILS FORM (OPTIONAL)
//             // 📌 SWITCH OUTSIDE CONTAINER
//             // 📌 BRINGING A VEHICLE SWITCH (OUTSIDE)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Bringing a Vehicle?",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     )),
//                 Switch.adaptive(
//                   value: hasVehicle,
//                   activeColor: Colors.black87,
//                   onChanged: (value) {
//                     setState(() {
//                       hasVehicle = value;
//                       if (value && vehicleDetails.isEmpty) {
//                         addNewVehicle(); // ✅ Add first vehicle form
//                       } else if (!value) {
//                         vehicleDetails
//                             .clear(); // ✅ Clear all forms if toggled off
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),

//             if (hasVehicle) ...[
//               SizedBox(height: 10.h),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: vehicleDetails.length,
//                 itemBuilder: (context, index) {
//                   final vehicle = vehicleDetails[index];
//                   return Padding(
//                     padding: EdgeInsets.only(bottom: 15.h),
//                     child: Stack(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(16.w),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(16.r),
//                             border: Border.all(color: Colors.grey.shade300),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 6,
//                                 spreadRadius: 1,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text("Vehicle ${index + 1}",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16.sp)),
//                               SizedBox(height: 8.h),
//                               TextField(
//                                 controller: vehicle['vehicleOwner'],
//                                 decoration: InputDecoration(
//                                   labelText: "Vehicle Owner",
//                                   hintText: "Enter owner's name",
//                                   labelStyle: TextStyle(color: Colors.black87),
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.r),
//                                     borderSide: BorderSide(color: Colors.grey),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 12.h),
//                               TextField(
//                                 controller: vehicle['plateNumber'],
//                                 decoration: InputDecoration(
//                                   labelText: "Plate Number",
//                                   hintText: "e.g. ABC-1234",
//                                   labelStyle: TextStyle(color: Colors.black87),
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.r),
//                                     borderSide: BorderSide(color: Colors.grey),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 12.h),
//                               TextField(
//                                 controller: vehicle['carType'],
//                                 decoration: InputDecoration(
//                                   labelText: "Car Type",
//                                   hintText: "e.g. SUV, Sedan, Truck",
//                                   labelStyle: TextStyle(color: Colors.black87),
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.r),
//                                     borderSide: BorderSide(color: Colors.grey),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 12.h),
//                             ],
//                           ),
//                         ),
//                         // ❌ Positioned Remove Button
//                         Positioned(
//                           top: 12,
//                           right: 12,
//                           child: GestureDetector(
//                             onTap: () => removeVehicle(index),
//                             child: Container(
//                               width: 20.w,
//                               height: 20.w,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.red[100],
//                                 border: Border.all(color: Colors.redAccent),
//                               ),
//                               child: Icon(
//                                 Icons.close,
//                                 size: 18,
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),

//               // 📌 Add Another Vehicle Button
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: TextButton.icon(
//                   onPressed: addNewVehicle,
//                   icon: Icon(Icons.add_circle_outline, color: Colors.black87),
//                   label: Text(
//                     "Add Another Vehicle",
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],

//             ElevatedButton(
//               onPressed: () {
//                 // Validate card type
//                 if (selectedCardType == null) {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: Text("Missing Information"),
//                       content:
//                           Text("Please select a card type before proceeding."),
//                       actions: [
//                         TextButton(
//                           child:
//                               Text("OK", style: TextStyle(color: Ec_PRIMARY)),
//                           onPressed: () => Navigator.of(context).pop(),
//                         ),
//                       ],
//                     ),
//                   );
//                   return;
//                 }

//                 // Validate passengers
//                 for (var i = 0; i < passengers.length; i++) {
//                   final passenger = passengers[i];
//                   if (passenger["name"]!.text.trim().isEmpty ||
//                       passenger["contact"]!.text.trim().isEmpty) {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text("Missing Passenger Details"),
//                         content: Text(
//                             "Please fill out all fields for Passenger ${i + 1}."),
//                         actions: [
//                           TextButton(
//                             child:
//                                 Text("OK", style: TextStyle(color: Ec_PRIMARY)),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                         ],
//                       ),
//                     );
//                     return;
//                   }
//                 }

//                 // Validate vehicle fields if applicable
//                 if (hasVehicle) {
//                   if (plateNumberController.text.trim().isEmpty ||
//                       carTypeController.text.trim().isEmpty) {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text("Incomplete Vehicle Details"),
//                         content: Text(
//                             "Please enter both the plate number and car type."),
//                         actions: [
//                           TextButton(
//                             child:
//                                 Text("OK", style: TextStyle(color: Ec_PRIMARY)),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                         ],
//                       ),
//                     );
//                     return;
//                   }
//                 }

//                 // Show confirmation dialog
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text("Confirm Details"),
//                     content:
//                         Text("Are you sure you want to proceed to payment?"),
//                     actions: [
//                       TextButton(
//                         child: Text("Cancel",
//                             style: TextStyle(color: Colors.grey)),
//                         onPressed: () => Navigator.of(context).pop(),
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Ec_PRIMARY,
//                         ),
//                         child: Text("Yes, Proceed",
//                             style: TextStyle(color: Colors.white)),
//                         onPressed: () {
//                           Navigator.of(context).pop(); // Close dialog
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PaymentScreen(
//                                 departureLocation: widget.departureLocation,
//                                 arrivalLocation: widget.arrivalLocation,
//                                 departDate: widget.departDate,
//                                 departTime: widget.departTime,
//                                 arriveDate: widget.arriveDate,
//                                 arriveTime: widget.arriveTime,
//                                 shippingLine: widget.shippingLine,
//                                 selectedCardType: selectedCardType!,
//                                 passengers: passengers
//                                     .map((p) => {
//                                           "name": p["name"]!.text,
//                                           "contact": p["contact"]!.text
//                                         })
//                                     .toList(),
//                                 hasVehicle: hasVehicle,
//                                 plateNumber: plateNumberController.text,
//                                 carType: carTypeController.text,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Ec_PRIMARY,
//                 padding: EdgeInsets.symmetric(vertical: 12.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//               ),
//               child: Center(
//                 child: Text("Proceed to Payment",
//                     style: TextStyle(fontSize: 18.sp, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
