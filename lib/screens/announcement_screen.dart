import 'package:EcBarko/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnnouncementsScreen extends StatelessWidget {
  final List<Map<String, String>> announcements = [
    {
      'title': '🌪️ Weather Advisory: Ferry Cancellations',
      'body':
          'Due to severe weather conditions, all ferry operations for today (May 15, 2025) have been cancelled. Please check our app for updates on rescheduled trips. Stay safe!'
    },
    {
      'title': '⚠️ Scheduled Maintenance',
      'body':
          'EcBarko will undergo maintenance on May 12, 2025, from 12:00 AM to 4:00 AM. During this time, ticketing and tracking features will be temporarily unavailable.'
    },
    {
      'title': '📱 New Feature Alert',
      'body':
          'Real-time ferry tracking is now live! Tap on "Track Ferry" from your dashboard to see estimated arrival and departure times.'
    },
    {
      'title': '🇵🇭 Independence Day Advisory',
      'body':
          'In observance of Independence Day, there will be no ferry operations on June 12, 2025. Please plan your trips accordingly.'
    },
    {
      'title': '🎫 Ticket Booking Reminder',
      'body':
          'Booking your ticket at least 24 hours before departure is highly recommended to avoid long queues and ensure a smooth boarding process.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final latest = announcements.first;

    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: Ec_PRIMARY,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Latest Announcement Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Ec_PRIMARY.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.new_releases, color: Ec_PRIMARY, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Latest Announcement',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Ec_PRIMARY,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Latest Announcement Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          latest['title']!.split(' ')[0],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Ec_PRIMARY,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          latest['title']!.substring(latest['title']!.indexOf(' ') + 1),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Ec_PRIMARY,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    latest['body']!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Ec_TEXT_COLOR_GREY,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // All Announcements List
            Text(
              'Previous Announcements',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Ec_PRIMARY,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                itemCount: announcements.length - 1,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = announcements[index + 1];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Ec_PRIMARY.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                item['title']!.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Ec_PRIMARY,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item['title']!.substring(item['title']!.indexOf(' ') + 1),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Ec_PRIMARY,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          item['body']!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Ec_TEXT_COLOR_GREY,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:EcBarko/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AnnouncementsScreen extends StatelessWidget {
//   final List<Map<String, String>> announcements = [
//     {
//       'title': '⚠️ Scheduled Maintenance',
//       'body':
//           'EcBarko will undergo maintenance on May 12, 2025, from 12:00 AM to 4:00 AM. During this time, ticketing and tracking features will be temporarily unavailable.'
//     },
//     {
//       'title': '📱 New Feature Alert',
//       'body':
//           'Real-time ferry tracking is now live! Tap on "Track Ferry" from your dashboard to see estimated arrival and departure times.'
//     },
//     {
//       'title': '🇵🇭 Independence Day Advisory',
//       'body':
//           'In observance of Independence Day, there will be no ferry operations on June 12, 2025. Please plan your trips accordingly.'
//     },
//     {
//       'title': '🎫 Ticket Booking Reminder',
//       'body':
//           'Booking your ticket at least 24 hours before departure is highly recommended to avoid long queues and ensure a smooth boarding process.'
//     },
//     {
//       'title': '💬 Need Help?',
//       'body':
//           'Our in-app support is now open from 8:00 AM to 6:00 PM daily. Tap the "Help Center" button to chat with an agent.'
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Announcements',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.sp,
//           ),
//         ),
//         backgroundColor: Ec_PRIMARY,
//         centerTitle: true,
//       ),
//       body: ListView.separated(
//         padding: EdgeInsets.all(16.w),
//         itemCount: announcements.length,
//         separatorBuilder: (_, __) => SizedBox(height: 12.h),
//         itemBuilder: (context, index) {
//           final item = announcements[index];
//           return Container(
//             padding: EdgeInsets.all(14.w),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Ec_PRIMARY.withOpacity(0.1)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 6,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item['title']!,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Ec_PRIMARY,
//                   ),
//                 ),
//                 SizedBox(height: 6.h),
//                 Text(
//                   item['body']!,
//                   style: TextStyle(
//                     fontSize: 13.5.sp,
//                     color: Ec_TEXT_COLOR_GREY,
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
