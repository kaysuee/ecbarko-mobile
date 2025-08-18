import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/announcement_screen.dart';
import 'package:EcBarko/screens/buyload_screen.dart';
import 'package:EcBarko/screens/linked_card_screen.dart';
import 'package:EcBarko/screens/notification_screen.dart';
import 'package:EcBarko/screens/profile_screen.dart';
import 'package:EcBarko/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import 'rates_screen.dart';
import 'booking_screen.dart';
import '../widgets/dashboard_sched_card.dart';
import '../widgets/dashboard_rates_card.dart';
import '../controllers/dashboard_data.dart';
import '../widgets/bounce_tap_wrapper.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo hide Center;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, this.userName = "User"});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isBalanceVisible = true;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? cardData;
  // Sample active booking data - replace with actual data source
  final Map<String, dynamic>? activeBooking = {
    'bookingId': 'BK-2024-10001',
    'departureLocation': 'Lucena',
    'arrivalLocation': 'Marinduque',
    'departDate': 'June 4 (Tuesday)',
    'departTime': '03:30 AM',
    'status': 'active',
    'shippingLine': 'STARHORSE Shipping Lines',
  };
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCard();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      print("userId is $userId");
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    }
  }

  Future<void> _loadCard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/card/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cardData = jsonDecode(response.body);
        });
      } else {
        print('Failed to load card data: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hello, ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: userData?['name'] ?? 'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          // top: MediaQuery.of(context).padding.top + 5.h,
          top: 0,
          left: 5.w,
          right: 5.w,
          bottom: 80.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRFIDImage(context),
            SizedBox(height: 3.h),

            _buildCardActionRow(context),
            SizedBox(height: 3.h),

            _buildAnnouncementSection(context),
            SizedBox(height: 3.h),
            // Show active booking if exists
            if (activeBooking != null) ...[
              _buildActiveBookingCard(context),
              SizedBox(height: 3.h),
            ],

            _buildBookSection(context),
            SizedBox(height: 3.h),
            SizedBox(height: 10.h),
            _buildRateCards(context),
          ],
        ),
      ),
    );
  }

  // Widget _buildRFIDImage(BuildContext context) {
  //   return BounceTapWrapper(
  //     onTap: () =>
  //         _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
  //     child: Card(
  //       color: Ec_PRIMARY,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       elevation: 8,
  //       margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
  //       child: Container(
  //         width: double.infinity,
  //         height: 220.h,
  //         padding: EdgeInsets.all(18.w),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(16.r),
  //           gradient: const RadialGradient(
  //             center: Alignment.center,
  //             radius: 1.0,
  //             colors: [
  //               Color(0xFF1A5A91),
  //               Color(0xFF142F60),
  //             ],
  //             stops: [0.3, 1.0],
  //           ),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Image.asset(
  //                   'assets/images/ecbarkowhitelogo.png',
  //                   width: 60.w,
  //                   height: 60.w,
  //                 ),
  //                 Text(
  //                   'RFID CARD',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 25.sp,
  //                     fontWeight: FontWeight.w700,
  //                     letterSpacing: 1.2,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 30.h),
  //             Row(
  //               children: [
  //                 Text(
  //                   'Available Balance',
  //                   style: TextStyle(
  //                     color: Colors.white.withOpacity(0.9),
  //                     fontSize: 25.sp,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 SizedBox(width: 8.w),
  //                 GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       isBalanceVisible = !isBalanceVisible;
  //                     });
  //                   },
  //                   child: Icon(
  //                     isBalanceVisible
  //                         ? Icons.visibility
  //                         : Icons.visibility_off,
  //                     color: Colors.white.withOpacity(0.8),
  //                     size: 25.sp,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 4.h),
  //             Text(
  //               isBalanceVisible == true
  //                   ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
  //                   : '•••••••••',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 40.sp,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildRFIDImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Use a fraction of screen height for the card height
    final cardHeight = screenHeight * 0.28; // ~28% of screen height

    return BounceTapWrapper(
      onTap: () =>
          _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
      child: Card(
        color: Ec_PRIMARY,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(screenWidth * 0.04), // 4% of width
        ),
        elevation: 8,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, // 3% horizontal margin
          vertical: screenHeight * 0.01, // 1% vertical margin
        ),
        child: Container(
          width: double.infinity,
          height: cardHeight,
          padding: EdgeInsets.all(screenWidth * 0.045), // 4.5% padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF1A5A91),
                Color(0xFF142F60),
              ],
              stops: [0.3, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/ecbarkowhitelogo.png',
                    width: screenWidth * 0.13, // 13% of screen width
                    height: screenWidth * 0.13,
                  ),
                  Text(
                    'RFID CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.065, // responsive font size
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04), // 4% spacing
              Row(
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: screenWidth * 0.040, // responsive font size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBalanceVisible = !isBalanceVisible;
                      });
                    },
                    child: Icon(
                      isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.8),
                      size: screenWidth * 0.065,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                isBalanceVisible
                    ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
                    : '••••••',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.08, // responsive big font
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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
          _buildCardActionButton(
            context,
            icon: Icons.history,
            label: 'History',
            onTap: () => _navigateTo(context, const HistoryScreen()),
          ),
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

  Widget _buildAnnouncementSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnnouncementsScreen()),
        );
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Ec_PRIMARY.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: Ec_PRIMARY,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Announcement',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Ec_PRIMARY,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Tap to view all announcements and updates from the team.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Ec_TEXT_COLOR_GREY,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active Booking Card Widget
  Widget _buildActiveBookingCard(BuildContext context) {
    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const BookingScreen(showBackButton: true),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Active Booking',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Ec_PRIMARY,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Booking ID
            Text(
              'Booking ID: ${activeBooking!['bookingId']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Ec_TEXT_COLOR_GREY,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 12.h),

            // Route Information
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10.sp,
                  color: Ec_PRIMARY,
                ),
                SizedBox(width: 8.w),
                Text(
                  activeBooking!['departureLocation'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_BLACK,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 1.h,
                    color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
                  ),
                ),
                Icon(
                  Icons.directions_boat,
                  color: Ec_PRIMARY,
                  size: 20.sp,
                ),
                Expanded(
                  child: Container(
                    height: 1.h,
                    color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  activeBooking!['arrivalLocation'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_BLACK,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.location_on,
                  size: 10.sp,
                  color: Ec_PRIMARY,
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16.sp,
                  color: Ec_TEXT_COLOR_GREY,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${activeBooking!['departDate']} at ${activeBooking!['departTime']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Ec_BLACK,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Shipping Line
            Text(
              activeBooking!['shippingLine'],
              style: TextStyle(
                fontSize: 13.sp,
                color: Ec_TEXT_COLOR_GREY,
                fontStyle: FontStyle.italic,
              ),
            ),

            SizedBox(height: 16.h),

            // Quick Action Button
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Booking Details',
                      style: TextStyle(
                        color: Ec_PRIMARY,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Ec_PRIMARY,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSection(BuildContext context) {
    final schedules = DashboardData.getSchedules().take(3).toList();

    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const BookingScreen(showBackButton: true, initialTab: 1),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.directions_boat_rounded,
                        color: Ec_PRIMARY,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Book a Trip',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Ec_PRIMARY,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Column(
              children: schedules.asMap().entries.map((entry) {
                final index = entry.key;
                final schedule = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < schedules.length - 1 ? 8.h : 0),
                  child: _buildEnhancedScheduleCard(
                    date: schedule['date'] ?? '',
                    from: schedule['from'] ?? '',
                    to: schedule['to'] ?? '',
                    time: schedule['time'] ?? '',
                    bgColor: schedule['color'] ?? Colors.grey,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Schedules',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.black54,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedScheduleCard({
    required String date,
    required String from,
    required String to,
    required String time,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Ec_BG_SKY_BLUE,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Ec_PRIMARY.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Ec_PRIMARY,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  date.split(' ')[0],
                  style: TextStyle(
                    color: Ec_WHITE,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date.split(' ')[1],
                  style: TextStyle(
                    color: Ec_WHITE,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10.sp,
                      color: Ec_PRIMARY,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      from,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Ec_BLACK,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 4.w),
                  height: 14.h,
                  width: 2.w,
                  color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 10.sp,
                      color: Ec_PRIMARY,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      to,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Ec_BLACK,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Ec_WHITE,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Ec_PRIMARY,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCards(BuildContext context) {
    final rateItems = DashboardData.getRateItems();

    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const RatesScreen(showBackButton: true),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        color: Ec_PRIMARY,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Ferry Rates',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Ec_PRIMARY,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'View Rates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: rateItems.map((item) {
                final isVehicle = item['label']
                        ?.toString()
                        .toLowerCase()
                        .contains('vehicle') ??
                    false;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: BounceTapWrapper(
                      onTap: () => _navigateTo(
                        context,
                        RatesScreen(
                          showBackButton: true,
                          initialVehicleTab: isVehicle,
                        ),
                      ),
                      child: Container(
                        height: 105.h,
                        decoration: BoxDecoration(
                          color: item['bgColor'] ?? Ec_BG_SKY_BLUE,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Ec_PRIMARY.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['label'] ?? '',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: item['textColor'] ?? Ec_BLACK,
                              ),
                            ),
                            if (item['imagePath'] != null)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  item['imagePath'].toString(),
                                  height: 50.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All Rates',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.black54,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
