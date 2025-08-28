// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:EcBarko/constants.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with ResponsiveWidgetMixin {
  List<NotificationModel> notifications = [];
  String selectedFilterType = 'All';
  bool isLoading = true;
  String? userId;

  List<NotificationModel> get filteredNotifications {
    if (selectedFilterType == 'All') return notifications.reversed.toList();
    return notifications
        .where((n) => n.type.toLowerCase() == selectedFilterType.toLowerCase())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userID');
      final token = prefs.getString('token');

      print('🔍 Debug: userID = $currentUserId');
      print('🔍 Debug: token = ${token != null ? 'Present' : 'Missing'}');

      if (currentUserId != null && token != null) {
        setState(() {
          userId = currentUserId;
        });

        print('🔍 Debug: Fetching notifications for user: $currentUserId');

        final notificationsData =
            await NotificationService.getUserNotifications(
          userId: currentUserId,
        );

        print(
            '🔍 Debug: Received ${notificationsData.length} notifications from API');

        final List<NotificationModel> loadedNotifications = notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Sort by creation date (newest first)
        loadedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          notifications = loadedNotifications;
          isLoading = false;
        });

        print(
            '🔍 Debug: Successfully loaded ${notifications.length} notifications');
      } else {
        print('❌ Error: Missing userID or token');
        if (currentUserId == null) {
          print('❌ Error: userID is null');
        }
        if (token == null) {
          print('❌ Error: token is null');
        }

        setState(() {
          isLoading = false;
        });

        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                currentUserId == null
                    ? 'User ID not found. Please log in again.'
                    : 'Authentication token missing. Please log in again.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() {
        isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadNotifications();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await NotificationService.markNotificationAsRead(
        notificationId: notification.id,
        userId: userId!,
      );

      // Update local state
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = NotificationModel(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            userId: notification.userId,
            additionalData: notification.additionalData,
            createdAt: notification.createdAt,
            isRead: true,
          );
        }
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await NotificationService.deleteNotification(
        notificationId: notification.id,
        userId: userId!,
      );

      // Remove from local state
      setState(() {
        notifications.removeWhere((n) => n.id == notification.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete notification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isUrgent = notification.isUrgent;
    final title = notification.title;
    final message = notification.message;
    final timeAgo = notification.getTimeAgo();
    final icon = notification.getIcon();
    final type = notification.type;

    return ResponsiveContainer(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacingM),
      padding: ResponsiveUtils.cardPadding,
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFF1F9FF),
        borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isUrgent
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 300;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isCompact ? 40.w : 48.w,
                height: isCompact ? 40.w : 48.w,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(ResponsiveUtils.cardRadius),
                ),
                child: Center(
                  child: ResponsiveText(
                    icon,
                    fontSize: isCompact ? 20 : 24,
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
                            fontSize: isCompact ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: notification.isRead
                                ? Colors.black87
                                : Colors.black,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUrgent)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: ResponsiveText(
                              'URGENT',
                              color: Colors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.spacingS),
                    ResponsiveText(
                      message,
                      fontSize: isCompact ? 13 : 14,
                      color: Colors.grey[600],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.spacingM),
                    Row(
                      children: [
                        ResponsiveText(
                          timeAgo,
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        if (!notification.isRead) ...[
                          SizedBox(width: ResponsiveUtils.spacingM),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      if (!notification.isRead) {
                        _markAsRead(notification);
                      }
                      break;
                    case 'delete':
                      _deleteNotification(notification);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: ResponsiveUtils.iconSizeM),
                          SizedBox(width: ResponsiveUtils.spacingM),
                          ResponsiveText('Mark as Read'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.red, size: ResponsiveUtils.iconSizeM),
                        SizedBox(width: ResponsiveUtils.spacingM),
                        ResponsiveText('Delete', color: Colors.red),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                  size: ResponsiveUtils.iconSizeM,
                ),
              ),
            ],
          );
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: ResponsiveUtils.iconSizeM,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: ResponsiveText(
          'Notifications',
          fontSize: ResponsiveUtils.fontSizeXXXL,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ResponsiveUtils.iconSizeM,
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_all,
                color: Colors.white,
                size: ResponsiveUtils.iconSizeM,
              ),
              onPressed: () => _showClearAllDialog(),
            ),
          // Test button for debugging
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: Colors.white,
              size: ResponsiveUtils.iconSizeM,
            ),
            onPressed: () => _createTestNotification(),
          ),
        ],
      ),
      body: ResponsiveContainer(
        padding: ResponsiveUtils.screenPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Ec_DARK_PRIMARY),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilterType,
                  isExpanded: true,
                  items: ['All', 'Order', 'Payment', 'System']
                      .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: ResponsiveText(
                              _getFilterDisplayName(value),
                              fontSize: ResponsiveUtils.fontSizeM,
                            ),
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
            SizedBox(height: ResponsiveUtils.spacingM),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredNotifications.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            children: filteredNotifications
                                .map(_buildNotificationItem)
                                .toList(),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterDisplayName(String filterType) {
    switch (filterType) {
      case 'Order':
        return 'Order';
      case 'Payment':
        return 'Payment';
      case 'System':
        return 'System';
      default:
        return filterType;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: ResponsiveUtils.iconSizeXL * 1.67,
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'No notifications yet',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'You\'ll see notifications here when you have updates',
            fontSize: ResponsiveUtils.fontSizeL,
            color: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content:
            const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllNotifications();
            },
            child:
                const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllNotifications() async {
    try {
      // Delete all notifications from the backend
      for (final notification in notifications) {
        await NotificationService.deleteNotification(
          notificationId: notification.id,
          userId: userId!,
        );
      }

      // Clear local state
      setState(() {
        notifications.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications cleared'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error clearing notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear some notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Test method to create a sample notification
  Future<void> _createTestNotification() async {
    try {
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not available. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('🔍 Creating test notification for user: $userId');

      await NotificationService.createNotification(
        type: 'test',
        title: 'Test Notification',
        message: 'This is a test notification to verify the system is working.',
        userId: userId!,
        additionalData: {
          'test': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('🔍 Test notification created successfully');

      // Refresh the notifications list
      await _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error creating test notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
