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

  Future<void> _archiveNotification(NotificationModel notification) async {
    try {
      // Update local state first for immediate UI feedback
      setState(() {
        notifications.removeWhere((n) => n.id == notification.id);
      });

      // Then update backend
      await NotificationService.archiveNotification(
        notificationId: notification.id,
        userId: userId!,
      );

      // Refresh notifications to ensure sync
      await _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification archived'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error archiving notification: $e');
      // Revert local state if backend update failed
      setState(() {
        notifications.add(notification);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to archive notification'),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: ResponsiveUtils.spacingM),
          padding: ResponsiveUtils.cardPadding,
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.grey[50] : Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? Colors.black.withOpacity(0.03)
                    : Colors.black.withOpacity(0.08),
                blurRadius: notification.isRead ? 4 : 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isUrgent
                ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
                : notification.isRead
                    ? Border.all(color: Colors.grey[300]!, width: 0.5)
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
                      color: _getNotificationColor(notification)
                          .withOpacity(notification.isRead ? 0.05 : 0.1),
                      borderRadius:
                          BorderRadius.circular(ResponsiveUtils.cardRadius),
                    ),
                    child: Center(
                      child: ResponsiveText(
                        icon,
                        fontSize: isCompact ? 20 : 24,
                        color: notification.isRead ? Colors.grey[600] : null,
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
                                    ? Colors.grey[600]
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
                          color: notification.isRead
                              ? Colors.grey[500]
                              : Colors.grey[600],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.spacingM),
                        Row(
                          children: [
                            ResponsiveText(
                              timeAgo,
                              fontSize: 11,
                              color: notification.isRead
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
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
                            ] else ...[
                              SizedBox(width: ResponsiveUtils.spacingM),
                              Icon(
                                Icons.check_circle,
                                size: 12.w,
                                color: Colors.green[600],
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
                        case 'archive':
                          _archiveNotification(notification);
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
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined,
                                color: Colors.orange,
                                size: ResponsiveUtils.iconSizeM),
                            SizedBox(width: ResponsiveUtils.spacingM),
                            ResponsiveText('Archive', color: Colors.orange),
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
          if (notifications.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                Icons.mark_email_read,
                color: Colors.white,
                size: ResponsiveUtils.iconSizeM,
              ),
              onPressed: () => _showMarkAllAsReadDialog(),
              tooltip: 'Mark All as Read',
            ),
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
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
              size: ResponsiveUtils.iconSizeM,
            ),
            onPressed: () => _showNotificationHistory(),
            tooltip: 'View History',
          ),
        ],
      ),
      body: ResponsiveContainer(
        padding: ResponsiveUtils.screenPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section with Clean Design (exactly like schedule screen)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: ElevatedButton.icon(
                      onPressed: () => _showTypeFilter(),
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
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: ElevatedButton.icon(
                      onPressed: () => _showStatusFilter(),
                      icon: const Icon(Icons.sort, color: Colors.white),
                      label: Text('Filter',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_PRIMARY,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
        title: const Text('Clear All Notifications'),
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
              await _clearAllNotifications();
            },
            child:
                const Text('Clear All', style: TextStyle(color: Colors.white)),
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

  Future<void> _clearAllNotifications() async {
    try {
      // Mark all notifications as archived in the backend (moved to history)
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
          content: Text('All notifications cleared and moved to history'),
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

  void _resetFilters() {
    setState(() {
      selectedFilterType = 'All';
      selectedReadStatus = 'All';
    });
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
              Icon(
                Icons.category,
                color: Ec_PRIMARY,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Filter by Type',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption(
                    context: context,
                    title: 'All Types',
                    subtitle: 'Show all notifications',
                    value: 'All',
                    groupValue: selectedFilterType,
                    icon: Icons.all_inclusive,
                    color: Colors.blue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  _buildFilterOption(
                    context: context,
                    title: 'Booking',
                    subtitle: 'Booking updates & reminders',
                    value: 'Booking',
                    groupValue: selectedFilterType,
                    icon: Icons.book_online,
                    color: Colors.green,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  _buildFilterOption(
                    context: context,
                    title: 'Card',
                    subtitle: 'Card transactions & updates',
                    value: 'Card',
                    groupValue: selectedFilterType,
                    icon: Icons.credit_card,
                    color: Colors.orange,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  _buildFilterOption(
                    context: context,
                    title: 'Profile',
                    subtitle: 'Account & security updates',
                    value: 'Profile',
                    groupValue: selectedFilterType,
                    icon: Icons.person,
                    color: Colors.purple,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  _buildFilterOption(
                    context: context,
                    title: 'System',
                    subtitle: 'App updates & announcements',
                    value: 'System',
                    groupValue: selectedFilterType,
                    icon: Icons.settings,
                    color: Colors.red,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.sp,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.sort,
                color: Ec_PRIMARY,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption(
                    context: context,
                    title: 'All Status',
                    subtitle: 'Show all notifications',
                    value: 'All',
                    groupValue: selectedReadStatus,
                    icon: Icons.all_inclusive,
                    color: Colors.blue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReadStatus = newValue!;
                      });
                    },
                  ),
                  _buildFilterOption(
                    context: context,
                    title: 'Read',
                    subtitle: 'Notifications you\'ve seen',
                    value: 'Read',
                    groupValue: selectedReadStatus,
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReadStatus = newValue!;
                      });
                    },
                  ),
                  _buildFilterOption(
                    context: context,
                    title: 'Unread',
                    subtitle: 'New notifications',
                    value: 'Unread',
                    groupValue: selectedReadStatus,
                    icon: Icons.mark_email_unread,
                    color: Colors.orange,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReadStatus = newValue!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.sp,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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

  Widget _buildFilterOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required IconData icon,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

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
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: color,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected
                          ? color.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: null,
      ),
    );
  }

  void _showMarkAllAsReadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark All as Read'),
          content: const Text(
            'Are you sure you want to mark all notifications as read? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context);
                await _markAllAsRead();
              },
              child: const Text('Mark All as Read',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      // Update local state first for immediate UI feedback
      setState(() {
        for (int i = 0; i < notifications.length; i++) {
          if (!notifications[i].isRead) {
            notifications[i] = NotificationModel(
              id: notifications[i].id,
              type: notifications[i].type,
              title: notifications[i].title,
              message: notifications[i].message,
              userId: notifications[i].userId,
              additionalData: notifications[i].additionalData,
              createdAt: notifications[i].createdAt,
              isRead: true,
              isArchived: notifications[i].isArchived,
            );
          }
        }
      });

      // Then update backend
      await NotificationService.markAllNotificationsAsRead(userId: userId!);

      // Refresh notifications to ensure sync
      await _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error marking all notifications as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to mark all notifications as read'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle notification tap to mark as read
  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      // Show immediate visual feedback
      setState(() {
        // Temporarily change the notification to show it's being processed
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

      // Mark as read in backend
      await _markAsRead(notification);
    }

    // You can add additional functionality here like:
    // - Navigate to a specific screen based on notification type
    // - Show detailed notification view
    // - Handle notification-specific actions

    // For now, just mark as read and show a subtle feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notification.title} - marked as read'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
