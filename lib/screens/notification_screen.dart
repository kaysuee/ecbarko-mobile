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
  String selectedReadStatus = 'All';
  bool isLoading = true;
  String? userId;

  List<NotificationModel> get filteredNotifications {
    List<NotificationModel> filtered = notifications;

    // Filter by type
    if (selectedFilterType != 'All') {
      // Map filter types to actual notification types
      final typeMapping = {
        'Booking': ['booking_created', 'booking_reminder'],
        'Card': ['card_loaded', 'card_linked', 'card_tapped'],
        'Profile': ['profile_update', 'password_update'],
        'System': ['system', 'general', 'test'],
      };

      final allowedTypes = typeMapping[selectedFilterType] ?? [];
      filtered = filtered.where((n) => allowedTypes.contains(n.type)).toList();
    }

    // Filter by read status
    if (selectedReadStatus != 'All') {
      if (selectedReadStatus == 'Read') {
        filtered = filtered.where((n) => n.isRead).toList();
      } else if (selectedReadStatus == 'Unread') {
        filtered = filtered.where((n) => !n.isRead).toList();
      }
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
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
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
              size: ResponsiveUtils.iconSizeM,
            ),
            onPressed: () => _showNotificationHistory(),
            tooltip: 'View History',
          ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_all,
                color: Colors.white,
                size: ResponsiveUtils.iconSizeM,
              ),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Clear Notifications',
            ),
        ],
      ),
      body: ResponsiveContainer(
        padding: ResponsiveUtils.screenPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section with Improved Design
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: ElevatedButton.icon(
                      onPressed: () => _showReadUnreadFilter(),
                      icon: const Icon(Icons.mark_email_read,
                          color: Colors.white),
                      label: Text('Read/Unread',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_PRIMARY,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 3,
                        shadowColor: Ec_PRIMARY.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: ElevatedButton.icon(
                      onPressed: _showTypeFilter,
                      icon: const Icon(Icons.category, color: Colors.white),
                      label: Text('Type',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_PRIMARY,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 3,
                        shadowColor: Ec_PRIMARY.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Show selected filters and clear option
            if (selectedFilterType != 'All' || selectedReadStatus != 'All') ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: Ec_PRIMARY,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Filtered: ${_getFilterDisplayText()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Ec_PRIMARY,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  void _showReadUnreadFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.mark_email_read,
                  color: Ec_PRIMARY,
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Filter by Read Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(
                  'All', 'All notifications', Icons.all_inclusive, Ec_PRIMARY),
              _buildFilterOption('Read', 'Read notifications',
                  Icons.mark_email_read, Colors.green),
              _buildFilterOption('Unread', 'Unread notifications',
                  Icons.mark_email_unread, Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
      String value, String label, IconData icon, Color color) {
    final isSelected = (value == 'All' && selectedReadStatus == 'All') ||
        (value == 'Read' && selectedReadStatus == 'Read') ||
        (value == 'Unread' && selectedReadStatus == 'Unread');

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedReadStatus,
        onChanged: (newValue) {
          setState(() {
            selectedReadStatus = newValue!;
          });
          Navigator.pop(context);
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
        activeColor: color,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }

  void _showTypeFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.category,
                  color: Ec_PRIMARY,
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Filter by Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeFilterOption(
                  'All', 'All types', Icons.all_inclusive, Ec_PRIMARY),
              _buildTypeFilterOption('Booking', 'Booking notifications',
                  Icons.confirmation_number, Colors.green),
              _buildTypeFilterOption('Card', 'Card notifications',
                  Icons.credit_card, Colors.purple),
              _buildTypeFilterOption('Profile', 'Profile notifications',
                  Icons.person, Colors.blue),
              _buildTypeFilterOption('System', 'System notifications',
                  Icons.settings, Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterOption(
      String value, String label, IconData icon, Color color) {
    final isSelected = (value == 'All' && selectedFilterType == 'All') ||
        (value == 'Booking' && selectedFilterType == 'Booking') ||
        (value == 'Card' && selectedFilterType == 'Card') ||
        (value == 'Profile' && selectedFilterType == 'Profile') ||
        (value == 'System' && selectedFilterType == 'System');

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedFilterType,
        onChanged: (newValue) {
          setState(() {
            selectedFilterType = newValue!;
          });
          Navigator.pop(context);
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
        activeColor: color,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedFilterType = 'All';
      selectedReadStatus = 'All';
    });
  }

  String _getFilterDisplayText() {
    List<String> activeFilters = [];

    if (selectedFilterType != 'All') {
      activeFilters.add(selectedFilterType);
    }
    if (selectedReadStatus != 'All') {
      activeFilters.add(selectedReadStatus);
    }

    return activeFilters.join(' + ');
  }
}
