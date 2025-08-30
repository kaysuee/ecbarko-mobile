import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';

class NotificationHistoryScreen extends StatefulWidget {
  final String userId;

  const NotificationHistoryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List<NotificationModel> archivedNotifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedNotifications();
  }

  Future<void> _loadArchivedNotifications() async {
    try {
      setState(() {
        isLoading = true;
      });

      final notificationsData =
          await NotificationService.getArchivedNotifications(
        userId: widget.userId,
      );

      final List<NotificationModel> loadedNotifications = notificationsData
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      // Sort by creation date (newest first)
      loadedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        archivedNotifications = loadedNotifications;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading archived notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadArchivedNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Notification History',
          fontSize: ResponsiveUtils.fontSizeL,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: Ec_DARK_PRIMARY,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ResponsiveUtils.iconSizeM,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: ResponsiveUtils.iconSizeM,
            ),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ResponsiveContainer(
        padding: ResponsiveUtils.screenPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : archivedNotifications.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            children: archivedNotifications
                                .map(_buildArchivedNotificationItem)
                                .toList(),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedNotificationItem(NotificationModel notification) {
    final title = notification.title;
    final message = notification.message;
    final timeAgo = notification.getTimeAgo();
    final icon = notification.getIcon();
    final type = notification.type;

    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {
            // You can add tap functionality here
            // Like showing full notification details
          },
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Very Compact Icon Container
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color:
                          _getNotificationColor(notification).withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: ResponsiveText(
                      icon,
                      fontSize: 14.sp,
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Type Badge Row
                      Row(
                        children: [
                          Expanded(
                            child: ResponsiveText(
                              title,
                              fontSize: ResponsiveUtils.fontSizeS,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: ResponsiveText(
                              type.toUpperCase().replaceAll('_', ' '),
                              color: Colors.grey[700],
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Message
                      ResponsiveText(
                        message,
                        fontSize: ResponsiveUtils.fontSizeXS,
                        color: Colors.grey[600],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Bottom Row with Time and Archived Badge
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: Ec_PRIMARY.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: Ec_PRIMARY.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Ec_PRIMARY,
                                  size: 8.sp,
                                ),
                                SizedBox(width: 2.w),
                                ResponsiveText(
                                  timeAgo,
                                  fontSize: 8.sp,
                                  color: Ec_PRIMARY,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.archive,
                                  color: Colors.orange[600],
                                  size: 8.sp,
                                ),
                                SizedBox(width: 2.w),
                                ResponsiveText(
                                  'ARCHIVED',
                                  color: Colors.orange[600],
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Color _getNotificationColor(NotificationModel notification) {
    switch (notification.getColor()) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: ResponsiveUtils.iconSizeXL * 1.67,
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'No Archived Notifications',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'Archived notifications will appear here',
            fontSize: ResponsiveUtils.fontSizeL,
            color: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
