// notifications_screen.dart
import 'package:EcBarko/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:EcBarko/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedView = 'All';
  String selectedFilterType = 'All';

  final List<NotificationModel> allNotifications = [
    NotificationModel(
      type: "Load",
      message: "₱100 Loaded to your card",
      date: DateTime(2025, 5, 1, 10, 30),
      isRead: false,
    ),
    NotificationModel(
      type: "Use",
      message: "You used ₱20 for Bus 042",
      date: DateTime(2025, 5, 1, 9, 15),
      isRead: false,
    ),
    NotificationModel(
      type: "System",
      message: "System maintenance at 11PM",
      date: DateTime(2025, 4, 29, 23, 0),
      isRead: true,
    ),
    NotificationModel(
      type: "Load",
      message: "Bonus ₱50 credited",
      date: DateTime(2025, 4, 28, 14, 45),
      isRead: false,
    ),
    NotificationModel(
      type: "System",
      message: "App updated to version 2.1.0",
      date: DateTime(2025, 4, 25, 19, 5),
      isRead: true,
    ),
    NotificationModel(
      type: "Load",
      message: "₱300 Loaded via GCash",
      date: DateTime(2025, 4, 24, 15, 0),
      isRead: false,
    ),
    NotificationModel(
      type: "Use",
      message: "You paid ₱18 for Ferry ride",
      date: DateTime(2025, 4, 23, 6, 45),
      isRead: false,
    ),
    NotificationModel(
      type: "System",
      message: "Scheduled downtime: May 5, 12AM–3AM",
      date: DateTime(2025, 4, 21, 20, 0),
      isRead: true,
    ),
    NotificationModel(
      type: "Use",
      message: "₱500 used for RORO Terminal Fee",
      date: DateTime(2025, 4, 20, 9, 15),
      isRead: false,
    ),
    NotificationModel(
      type: "Load",
      message: "₱500 loaded",
      date: DateTime(2025, 4, 19, 11, 25),
      isRead: true,
    ),
    NotificationModel(
      type: "Use",
      message: "₱22 used for PNR train fare",
      date: DateTime(2025, 4, 18, 7, 55),
      isRead: true,
    ),
    NotificationModel(
      type: "System",
      message: "You logged in on a new device",
      date: DateTime(2025, 4, 17, 17, 10),
      isRead: false,
    ),
    NotificationModel(
      type: "Promo",
      message: "Flash deal: 5% cashback on load today!",
      date: DateTime(2025, 4, 16, 10, 0),
      isRead: false,
    ),
    NotificationModel(
      type: "Load",
      message: "₱200 successfully reloaded",
      date: DateTime(2025, 4, 15, 18, 20),
      isRead: false,
    ),
    NotificationModel(
      type: "Use",
      message: "You used ₱40 for Night Bus service",
      date: DateTime(2025, 4, 14, 22, 10),
      isRead: true,
    ),
    NotificationModel(
      type: "System",
      message: "EcBarko Terms updated",
      date: DateTime(2025, 4, 13, 14, 50),
      isRead: true,
    ),
    NotificationModel(
      type: "Promo",
      message: "Congratulations! You earned a free ride.",
      date: DateTime(2025, 4, 12, 9, 30),
      isRead: false,
    ),
  ];

  List<NotificationModel> get filteredNotifications {
    List<NotificationModel> filtered = allNotifications;

    if (selectedFilterType != 'All') {
      filtered = filtered.where((n) => n.type == selectedFilterType).toList();
    }

    if (selectedView == 'Unread') {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    return filtered.reversed.toList();
  }

  Widget _buildNotificationItem(NotificationModel notif) {
    final formattedDate = DateFormat('dd MMM yyyy\nhh:mm a').format(notif.date);

    final Color badgeColor = {
          'Load': Colors.green,
          'Use': Colors.orange,
          'System': Colors.blueGrey,
          'Promo': Colors.purple,
        }[notif.type] ??
        Colors.grey;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              notif.isRead = true;
            });
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: notif.isRead ? Colors.white : const Color(0xFFF1F9FF),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getNotificationIcon(notif.type),
                    size: 24.sp,
                    color: badgeColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.message,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: notif.isRead
                                    ? Colors.black87
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              notif.type,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: badgeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Load':
        return Icons.account_balance_wallet;
      case 'Use':
        return Icons.directions_bus;
      case 'System':
        return Icons.settings;
      case 'Promo':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
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
          'Notifications',
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
        actions: [
          if (filteredNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications'),
                    content: const Text(
                        'Are you sure you want to clear all notifications?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            allNotifications.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildFilterButton('All'),
                      SizedBox(width: 16.w),
                      _buildFilterButton('Unread'),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilterType,
                        items: ['All', 'Load', 'Use', 'System', 'Promo']
                            .map((value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFilterType = value!;
                          });
                        },
                        icon: Icon(Icons.arrow_drop_down, color: Ec_PRIMARY),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      children: filteredNotifications
                          .map(_buildNotificationItem)
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final isSelected = selectedView == text;
    return GestureDetector(
      onTap: () => setState(() => selectedView = text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Ec_PRIMARY.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Ec_PRIMARY : Colors.black54,
          ),
        ),
      ),
    );
  }
}

// // notifications_screen.dart
// import 'package:EcBarko/models/notification_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:EcBarko/constants.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   String selectedView = 'All';
//   String selectedFilterType = 'All';

//   final List<NotificationModel> allNotifications = [
//     NotificationModel(
//       type: "Load",
//       message: "₱100 Loaded to your card",
//       date: DateTime(2025, 5, 1, 10, 30),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Use",
//       message: "You used ₱20 for Bus 042",
//       date: DateTime(2025, 5, 1, 9, 15),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "System",
//       message: "System maintenance at 11PM",
//       date: DateTime(2025, 4, 29, 23, 0),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "Load",
//       message: "Bonus ₱50 credited",
//       date: DateTime(2025, 4, 28, 14, 45),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Use",
//       message: "You paid ₱15 for Jeepney 305",
//       date: DateTime(2025, 4, 27, 8, 10),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "Promo",
//       message: "New promo: Load ₱200, get ₱20 free!",
//       date: DateTime(2025, 4, 26, 12, 30),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "System",
//       message: "App updated to version 2.1.0",
//       date: DateTime(2025, 4, 25, 19, 5),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "Load",
//       message: "₱300 Loaded via GCash",
//       date: DateTime(2025, 4, 24, 15, 0),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Use",
//       message: "You paid ₱18 for Ferry ride",
//       date: DateTime(2025, 4, 23, 6, 45),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Promo",
//       message: "Refer a friend and earn ₱25!",
//       date: DateTime(2025, 4, 22, 13, 30),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "System",
//       message: "Scheduled downtime: May 5, 12AM–3AM",
//       date: DateTime(2025, 4, 21, 20, 0),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "Use",
//       message: "₱50 used for Van Terminal ride",
//       date: DateTime(2025, 4, 20, 9, 15),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Load",
//       message: "₱500 loaded from PayMaya",
//       date: DateTime(2025, 4, 19, 11, 25),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "Use",
//       message: "₱22 used for PNR train fare",
//       date: DateTime(2025, 4, 18, 7, 55),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "System",
//       message: "You logged in on a new device",
//       date: DateTime(2025, 4, 17, 17, 10),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Promo",
//       message: "Flash deal: 5% cashback on load today!",
//       date: DateTime(2025, 4, 16, 10, 0),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Load",
//       message: "₱200 successfully reloaded",
//       date: DateTime(2025, 4, 15, 18, 20),
//       isRead: false,
//     ),
//     NotificationModel(
//       type: "Use",
//       message: "You used ₱40 for Night Bus service",
//       date: DateTime(2025, 4, 14, 22, 10),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "System",
//       message: "EcBarko Terms updated",
//       date: DateTime(2025, 4, 13, 14, 50),
//       isRead: true,
//     ),
//     NotificationModel(
//       type: "Promo",
//       message: "Congratulations! You earned a free ride.",
//       date: DateTime(2025, 4, 12, 9, 30),
//       isRead: false,
//     ),
//   ];

//   List<NotificationModel> get filteredNotifications {
//     List<NotificationModel> filtered = allNotifications;

//     if (selectedFilterType != 'All') {
//       filtered = filtered.where((n) => n.type == selectedFilterType).toList();
//     }

//     if (selectedView == 'Unread') {
//       filtered = filtered.where((n) => !n.isRead).toList();
//     }

//     return filtered.reversed.toList();
//   }

//   Widget _buildNotificationItem(NotificationModel notif) {
//     final formattedDate = DateFormat('dd MMM yyyy\nhh:mm a').format(notif.date);

//     final Color badgeColor = {
//           'Load': Colors.green,
//           'Use': Colors.orange,
//           'System': Colors.blueGrey,
//           'Promo': Colors.purple,
//         }[notif.type] ??
//         Colors.grey;

//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               notif.isRead = true;
//             });
//           },
//           child: Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: notif.isRead ? Colors.white : const Color(0xFFF1F9FF),
//               borderRadius: BorderRadius.circular(12.r),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 48.w,
//                   height: 48.w,
//                   decoration: BoxDecoration(
//                     color: badgeColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Icon(
//                     _getNotificationIcon(notif.type),
//                     size: 24.sp,
//                     color: badgeColor,
//                   ),
//                 ),
//                 SizedBox(width: 16.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               notif.message,
//                               style: TextStyle(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: notif.isRead ? Colors.black87 : Colors.black,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//                             decoration: BoxDecoration(
//                               color: badgeColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20.r),
//                             ),
//                             child: Text(
//                               notif.type,
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 color: badgeColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 6.h),
//                       Text(
//                         formattedDate,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 12.h),
//       ],
//     );
//   }

//   IconData _getNotificationIcon(String type) {
//     switch (type) {
//       case 'Load':
//         return Icons.account_balance_wallet;
//       case 'Use':
//         return Icons.directions_bus;
//       case 'System':
//         return Icons.settings;
//       case 'Promo':
//         return Icons.local_offer;
//       default:
//         return Icons.notifications;
//     }
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_off_outlined,
//             size: 80.sp,
//             color: Colors.grey[400],
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'No notifications',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[600],
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'You\'re all caught up!',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Ec_BG_SKY_BLUE,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontFamily: 'Arial',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Ec_PRIMARY,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           if (filteredNotifications.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.white),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Clear All Notifications'),
//                     content: const Text('Are you sure you want to clear all notifications?'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Cancel'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             allNotifications.clear();
//                           });
//                           Navigator.pop(context);
//                         },
//                         child: const Text('Clear'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       _buildFilterButton('All'),
//                       SizedBox(width: 16.w),
//                       _buildFilterButton('Unread'),
//                     ],
//                   ),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: selectedFilterType,
//                         items: ['All', 'Load', 'Use', 'System', 'Promo']
//                             .map((value) => DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(
//                                     value,
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ))
//                             .toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedFilterType = value!;
//                           });
//                         },
//                         icon: Icon(Icons.arrow_drop_down, color: Ec_PRIMARY),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Expanded(
//               child: filteredNotifications.isEmpty
//                   ? _buildEmptyState()
//                   : ListView(
//                       children: filteredNotifications
//                           .map(_buildNotificationItem)
//                           .toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterButton(String text) {
//     final isSelected = selectedView == text;
//     return GestureDetector(
//       onTap: () => setState(() => selectedView = text),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: isSelected ? Ec_PRIMARY.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//             color: isSelected ? Ec_PRIMARY : Colors.black54,
//           ),
//         ),
//       ),
//     );
//   }
// }
