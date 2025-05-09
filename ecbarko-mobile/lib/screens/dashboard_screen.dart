import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/announcement_screen.dart';
import 'package:EcBarko/screens/buyload_screen.dart';
import 'package:EcBarko/screens/notification_screen.dart';
import 'package:EcBarko/screens/profile_screen.dart';
import 'package:EcBarko/screens/history_screen.dart';
// import 'package:EcBarko/widgets/dashboard_section_header.dart';
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

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, this.userName = "User"});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    // Remove SafeArea to eliminate top white padding
    return Scaffold(
      // Set background color to match the main scaffold
      backgroundColor: Ec_BG_SKY_BLUE,
      // Remove default appBar to eliminate white space at top
      appBar: null,
      // Use full screen for content
      body: SingleChildScrollView(
        // Start from the very top of the screen
        padding: EdgeInsets.only(
          // Add top padding to account for status bar
          top: MediaQuery.of(context).padding.top + 5.h,
          left: 5.w,
          right: 5.w,
          // Add extra padding at bottom for navigation bar
          bottom: 80.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 3.h),
            _buildRFIDImage(context),
            SizedBox(height: 3.h),
            _buildAnnouncementSection(context),
            SizedBox(height: 3.h),
            _buildBookSection(context),
            SizedBox(height: 3.h),
            // SectionHeader(
            //   title: 'Rates',
            //   onViewAll: () =>
            //       _navigateTo(context, const RatesScreen(showBackButton: true)),
            // ),
            SizedBox(height: 10.h),
            _buildRateCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Hello, ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Vicky!',
                  style: TextStyle(
                    color: Ec_PRIMARY,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsScreen()),
            ),
            child: Semantics(
              label: 'Notifications',
              child: const Icon(
                Icons.notifications_none,
                size: 40,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improved RFID Card Widget
  Widget _buildRFIDImage(BuildContext context) {
    return BounceTapWrapper(
      onTap: () =>
          _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
      child: Card(
        color: Ec_PRIMARY,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 8,
        // Remove default card margin
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Container(
          width: double.infinity,
          height: 220.h,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Ec_PRIMARY, Ec_DARK_PRIMARY.withOpacity(0.8)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header with logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logoWhite.png',
                    width: 40.w,
                    height: 40.w,
                  ),
                  Text(
                    'RFID CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Balance section
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 4.h),

              // Balance amount with toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isBalanceVisible ? '₱1,250.00' : '•••••••••',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
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
                      size: 18.sp,
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Action buttons
              Row(
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
                    icon: Icons.history,
                    label: 'History',
                    onTap: () => _navigateTo(context, const HistoryScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for card action buttons
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
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Announcement Section
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

  Widget _buildBookSection(BuildContext context) {
    final schedules = DashboardData.getSchedules().take(3).toList();

    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const BookingsScreen(showBackButton: true),
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
            // Header section
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

            // Featured schedules
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

            // View all button
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
        color: Ec_BG_SKY_BLUE, // Updated to a light calm blue
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Ec_PRIMARY.withOpacity(0.3), // Themed primary
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Date column
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Ec_PRIMARY, // Primary theme color
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  date.split(' ')[0], // Day
                  style: TextStyle(
                    color: Ec_WHITE,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date.split(' ')[1], // Month
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

          // Trip details
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

          // Time
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
            // Header section
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

            // Rate cards
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
                    child: Container(
                      height: 100.h,
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
                );
              }).toList(),
            ),

            SizedBox(height: 10.h),

            // View all button
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
  // Widget _buildRateCards(BuildContext context) {
  //   final rateItems = DashboardData.getRateItems();

  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: rateItems.map((item) {
  //       final isVehicle =
  //           item['label']?.toString().toLowerCase().contains('vehicle') ??
  //               false;

  //       return Expanded(
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 5.w),
  //           child: Material(
  //             color: Colors.transparent,
  //             child: InkWell(
  //               borderRadius: BorderRadius.circular(16.r),
  //               onTap: () => _navigateTo(
  //                 context,
  //                 RatesScreen(
  //                   showBackButton: true,
  //                   initialVehicleTab: isVehicle,
  //                 ),
  //               ),
  //               child: Container(
  //                 height: 60.h,
  //                 decoration: BoxDecoration(
  //                   color: item['bgColor'] ?? Colors.white,
  //                   borderRadius: BorderRadius.circular(16.r),
  //                   boxShadow: [
  //                     const BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         item['label'] ?? '',
  //                         style: TextStyle(
  //                           fontSize: 20.sp,
  //                           fontWeight: FontWeight.bold,
  //                           color: item['textColor'] ?? Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                     if (item['imagePath'] != null)
  //                       Image.asset(
  //                         item['imagePath'].toString(),
  //                         height: 50.h,
  //                         fit: BoxFit.contain,
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
