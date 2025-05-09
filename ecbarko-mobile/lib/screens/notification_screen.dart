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
      type: "Use",
      message: "You paid ₱15 for Jeepney 305",
      date: DateTime(2025, 4, 27, 8, 10),
      isRead: true,
    ),
    NotificationModel(
      type: "Promo",
      message: "New promo: Load ₱200, get ₱20 free!",
      date: DateTime(2025, 4, 26, 12, 30),
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
      type: "Promo",
      message: "Refer a friend and earn ₱25!",
      date: DateTime(2025, 4, 22, 13, 30),
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
      message: "₱50 used for Van Terminal ride",
      date: DateTime(2025, 4, 20, 9, 15),
      isRead: false,
    ),
    NotificationModel(
      type: "Load",
      message: "₱500 loaded from PayMaya",
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

    return GestureDetector(
      onTap: () {
        setState(() {
          notif.isRead = true;
        });
      },
      child: Container(
        // margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF1F9FF),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.notifications, size: 20.sp, color: Colors.blue),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.message,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4.h),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                notif.type,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedView = 'All'),
                      child: Text(
                        'All',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: selectedView == 'All'
                              ? Ec_PRIMARY
                              : Colors.black54,
                          decoration: selectedView == 'All'
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () => setState(() => selectedView = 'Unread'),
                      child: Text(
                        'Unread',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: selectedView == 'Unread'
                              ? Ec_PRIMARY
                              : Colors.black54,
                          decoration: selectedView == 'Unread'
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Ec_DARK_PRIMARY),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilterType,
                      items: ['All', 'Load', 'Use', 'System', 'Promo']
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
                    filteredNotifications.map(_buildNotificationItem).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
