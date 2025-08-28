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
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
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

      final notificationsData = await NotificationService.getArchivedNotifications(
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
            // Header Section
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.grey[600],
                    size: ResponsiveUtils.iconSizeM,
                  ),
                  SizedBox(width: ResponsiveUtils.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          'Archived Notifications',
                          fontSize: ResponsiveUtils.fontSizeL,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        SizedBox(height: ResponsiveUtils.spacingS),
                        ResponsiveText(
                          '${archivedNotifications.length} archived notifications',
                          fontSize: ResponsiveUtils.fontSizeS,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacingM),
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

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacingM),
      padding: ResponsiveUtils.cardPadding,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
            ),
            child: Center(
              child: ResponsiveText(
                icon,
                fontSize: 24,
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ResponsiveText(
                        title,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: ResponsiveText(
                        'ARCHIVED',
                        color: Colors.grey[600],
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.spacingS),
                ResponsiveText(
                  message,
                  fontSize: 14,
                  color: Colors.grey[600],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.spacingM),
                ResponsiveText(
                  timeAgo,
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
