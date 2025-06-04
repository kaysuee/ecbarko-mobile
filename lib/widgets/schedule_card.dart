import 'package:EcBarko/constants.dart';
import 'package:EcBarko/screens/bookingdetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleCard extends StatelessWidget {
  final String departureLocation;
  final String departurePort;
  final String arrivalLocation;
  final String arrivalPort;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final int passengerSlotsLeft;
  final int vehicleSlotsLeft;

  const ScheduleCard({
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
    required this.passengerSlotsLeft,
    required this.vehicleSlotsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showConfirmationDialog(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 LOCATIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(departureLocation,
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Ec_PRIMARY)),
                      Text(departurePort,
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.black)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(arrivalLocation,
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Ec_PRIMARY)),
                      Text(arrivalPort,
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.black)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // 🔵 PATH VISUAL
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: Ec_PRIMARY,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Container(width: 129.w, height: 2.h, color: Ec_PRIMARY),
                  SizedBox(width: 5.w),
                  Icon(Icons.directions_boat, color: Ec_PRIMARY, size: 40.sp),
                  SizedBox(width: 5.w),
                  Container(width: 129.w, height: 2.h, color: Ec_PRIMARY),
                  SizedBox(width: 5.w),
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: Ec_PRIMARY,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // 🔵 TIME INFO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Depart',
                          style: TextStyle(fontSize: 14.sp, color: Ec_PRIMARY)),
                      Text(departDate,
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      Text(departTime,
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Arrive',
                          style: TextStyle(fontSize: 14.sp, color: Ec_PRIMARY)),
                      Text(arriveDate,
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      Text(arriveTime,
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // 🔵 SHIPPING LINE
              Center(
                child: Text(
                  shippingLine,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Ec_PRIMARY,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // 🧍‍♂️🚗 SLOT INDICATORS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 18.sp, color: Colors.green),
                      SizedBox(width: 5.w),
                      Text(
                        '$passengerSlotsLeft Pax Left',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.directions_car,
                          size: 18.sp, color: Colors.blue),
                      SizedBox(width: 5.w),
                      Text(
                        '$vehicleSlotsLeft Vehicles Left',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Schedule"),
          content: Text(
              "Do you want to proceed with the schedule from $departureLocation to $arrivalLocation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsScreen(
                      departureLocation: departureLocation,
                      departurePort: departurePort,
                      arrivalLocation: arrivalLocation,
                      arrivalPort: arrivalPort,
                      departDate: departDate,
                      departTime: departTime,
                      arriveDate: arriveDate,
                      arriveTime: arriveTime,
                      shippingLine: shippingLine,
                    ),
                  ),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
