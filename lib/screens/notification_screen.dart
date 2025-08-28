// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_history_screen.dart';

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
    if (selectedFilterType == 'All') return notifications;

    // Map filter types to actual notification types
    final typeMapping = {
      'Booking': ['booking_created', 'booking_reminder'],
      'Card': ['card_loaded', 'card_linked', 'card_tapped'],
      'Profile': ['profile_update', 'password_update'],
      'System': ['system', 'general', 'test'],
    };

    final allowedTypes = typeMapping[selectedFilterType] ?? [];
    return notifications.where((n) => allowedTypes.contains(n.type)).toList()
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

      if (currentUserId != null && token != null) {
        setState(() {
          userId = currentUserId;
        });

        final notificationsData =
            await NotificationService.getUserNotifications(
          userId: currentUserId,
        );

        final List<NotificationModel> loadedNotifications = notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Sort by creation date (newest first)
        loadedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          notifications = loadedNotifications;
          isLoading = false;
        });
      } else {
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
      // Update local state first for immediate UI feedback
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
            isArchived: notification.isArchived,
          );
        }
      });

      // Then update backend
      await NotificationService.markNotificationAsRead(
        notificationId: notification.id,
        userId: userId!,
      );

      // Refresh notifications to ensure sync
      await _loadNotifications();
    } catch (e) {
      print('Error marking notification as read: $e');
      // Revert local state if backend update failed
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
            isRead: notification.isRead,
            isArchived: notification.isArchived,
          );
        }
      });
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      // Update local state first for immediate UI feedback
      setState(() {
        notifications.removeWhere((n) => n.id == notification.id);
      });

      // Then update backend
      await NotificationService.deleteNotification(
        notificationId: notification.id,
        userId: userId!,
      );

      // Refresh notifications to ensure sync
      await _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification removed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting notification: $e');
      // Revert local state if backend update failed
      setState(() {
        notifications.add(notification);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove notification'),
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
                Icons.history,
                color: Colors.white,
                size: ResponsiveUtils.iconSizeM,
              ),
              onPressed: () => _showNotificationHistory(),
              tooltip: 'View History',
            ),
          IconButton(
            icon: Icon(
              Icons.clear_all,
              color: Colors.white,
              size: ResponsiveUtils.iconSizeM,
            ),
            onPressed: () => _showClearAllDialog(),
            tooltip: 'Archive All',
          ),
        ],
      ),
      body: ResponsiveContainer(
        padding: ResponsiveUtils.screenPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Summary Section
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Ec_DARK_PRIMARY.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Ec_DARK_PRIMARY.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          'Total Notifications',
                          fontSize: ResponsiveUtils.fontSizeS,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: ResponsiveUtils.spacingS),
                        ResponsiveText(
                          '${notifications.length}',
                          fontSize: ResponsiveUtils.fontSizeXL,
                          fontWeight: FontWeight.bold,
                          color: Ec_DARK_PRIMARY,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ResponsiveText(
                          'Unread',
                          fontSize: ResponsiveUtils.fontSizeS,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: ResponsiveUtils.spacingS),
                        ResponsiveText(
                          '${notifications.where((n) => !n.isRead).length}',
                          fontSize: ResponsiveUtils.fontSizeXL,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ResponsiveText(
                          'Latest',
                          fontSize: ResponsiveUtils.fontSizeS,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: ResponsiveUtils.spacingS),
                        ResponsiveText(
                          notifications.isNotEmpty
                              ? notifications.first.getTimeAgo()
                              : 'None',
                          fontSize: ResponsiveUtils.fontSizeS,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacingM),
            // Enhanced Filter Section
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Ec_DARK_PRIMARY,
                        size: ResponsiveUtils.iconSizeM,
                      ),
                      SizedBox(width: ResponsiveUtils.spacingS),
                      ResponsiveText(
                        'Filter Notifications',
                        fontSize: ResponsiveUtils.fontSizeL,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.spacingM),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                            'All', Icons.all_inclusive, Ec_DARK_PRIMARY),
                        SizedBox(width: ResponsiveUtils.spacingS),
                        _buildFilterChip(
                            'Booking', Icons.confirmation_number, Colors.green),
                        SizedBox(width: ResponsiveUtils.spacingS),
                        _buildFilterChip(
                            'Card', Icons.credit_card, Colors.purple),
                        SizedBox(width: ResponsiveUtils.spacingS),
                        _buildFilterChip('Profile', Icons.person, Colors.blue),
                        SizedBox(width: ResponsiveUtils.spacingS),
                        _buildFilterChip(
                            'System', Icons.settings, Colors.orange),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    final isSelected = selectedFilterType == label;
    final notificationCount = _getNotificationCount(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilterType = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacingM,
          vertical: ResponsiveUtils.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.iconSizeS,
              color: isSelected ? Colors.white : color,
            ),
            SizedBox(width: ResponsiveUtils.spacingS),
            ResponsiveText(
              label,
              fontSize: ResponsiveUtils.fontSizeS,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : color,
            ),
            if (notificationCount > 0) ...[
              SizedBox(width: ResponsiveUtils.spacingS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: ResponsiveText(
                  notificationCount.toString(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getNotificationCount(String filterType) {
    if (filterType == 'All') return notifications.length;

    // Map filter types to actual notification types
    final typeMapping = {
      'Booking': ['booking_created', 'booking_reminder'],
      'Card': ['card_loaded', 'card_linked', 'card_tapped'],
      'Profile': ['profile_update', 'password_update'],
      'System': ['system', 'general', 'test'],
    };

    final allowedTypes = typeMapping[filterType] ?? [];
    return notifications.where((n) => allowedTypes.contains(n.type)).length;
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
        title: const Text('Archive All Notifications'),
        content: const Text(
          'This will move all notifications to your notification history. You can still view them later, but they won\'t appear in your main notifications list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              Navigator.pop(context);
              await _archiveAllNotifications();
            },
            child: const Text('Archive All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationHistoryScreen(userId: userId!),
      ),
    );
  }

  Future<void> _archiveAllNotifications() async {
    try {
      // Mark all notifications as archived in the backend
      for (final notification in notifications) {
        await NotificationService.archiveNotification(
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
          content: Text('All notifications archived'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error archiving notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to archive some notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
