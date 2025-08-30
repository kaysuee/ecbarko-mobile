import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../utils/responsive_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  List<AnnouncementModel> announcements = [];
  String selectedFilterType = 'All';
  String selectedPriority = 'All';
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final currentUserId =
          prefs.getString('userId') ?? prefs.getString('userID');

      if (currentUserId != null) {
        setState(() {
          userId = currentUserId;
        });

        print('🔍 Fetching announcements for user: $currentUserId');
        print('🔍 User ID type: ${currentUserId.runtimeType}');
        print('🔍 User ID length: ${currentUserId.length}');

        final announcementsData =
            await AnnouncementService.getUserAnnouncements(
          userId: currentUserId,
          type: selectedFilterType != 'All' ? selectedFilterType : null,
          priority: selectedPriority != 'All' ? selectedPriority : null,
        );

        print('📊 Raw announcements data: $announcementsData');
        print('📊 Announcements count: ${announcementsData.length}');

        final List<AnnouncementModel> loadedAnnouncements = announcementsData
            .map((json) => AnnouncementModel.fromJson(json))
            .toList();

        print('✅ Parsed announcements: ${loadedAnnouncements.length}');

        // Sort by priority and creation date (highest priority first, then newest)
        loadedAnnouncements.sort((a, b) {
          final priorityOrder = {
            'critical': 4,
            'high': 3,
            'medium': 2,
            'low': 1
          };
          final aPriority = priorityOrder[a.priority] ?? 0;
          final bPriority = priorityOrder[b.priority] ?? 0;

          if (aPriority != bPriority) {
            return bPriority.compareTo(aPriority);
          }
          return b.dateCreated.compareTo(a.dateCreated);
        });

        setState(() {
          announcements = loadedAnnouncements;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading announcements: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAnnouncements();
  }

  Future<void> _markAsRead(AnnouncementModel announcement) async {
    if (announcement.isReadBy(userId!)) return;

    try {
      await AnnouncementService.markAnnouncementAsRead(
        announcementId: announcement.id,
        userId: userId!,
      );

      // Refresh announcements to update read status
      await _loadAnnouncements();
    } catch (e) {
      print('Error marking announcement as read: $e');
    }
  }

  List<AnnouncementModel> get filteredAnnouncements {
    List<AnnouncementModel> filtered = announcements;

    // Filter out test announcements
    filtered = filtered
        .where((a) =>
            !a.title.toLowerCase().contains('test') &&
            !a.message.toLowerCase().contains('test'))
        .toList();

    // Filter by type
    if (selectedFilterType != 'All') {
      filtered = filtered
          .where((a) => a.type == selectedFilterType.toLowerCase())
          .toList();
    }

    // Filter by priority
    if (selectedPriority != 'All') {
      filtered = filtered
          .where((a) => a.priority == selectedPriority.toLowerCase())
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Announcements',
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
            // Filter Section with Improved Design
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showTypeFilter();
                      },
                      icon: const Icon(Icons.category, color: Colors.white),
                      label: Text('Type',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_DARK_PRIMARY,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 3,
                        shadowColor: Ec_DARK_PRIMARY.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showPriorityFilter();
                      },
                      icon:
                          const Icon(Icons.priority_high, color: Colors.white),
                      label: Text('Priority',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_DARK_PRIMARY,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 3,
                        shadowColor: Ec_DARK_PRIMARY.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Show selected filters and clear option
            if (selectedFilterType != 'All' || selectedPriority != 'All') ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Ec_DARK_PRIMARY.withOpacity(0.3)),
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
                      color: Ec_DARK_PRIMARY,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Filtered: ${_getFilterDisplayText()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Ec_DARK_PRIMARY,
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

            // Announcements List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredAnnouncements.isEmpty
                        ? _buildEmptyState()
                        : ListView(
                            children: filteredAnnouncements
                                .map(_buildAnnouncementItem)
                                .toList(),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(AnnouncementModel announcement) {
    final isRead = announcement.isReadBy(userId ?? '');
    final isUrgent = announcement.isUrgent;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.spacingM),
      padding: ResponsiveUtils.cardPadding,
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF1F9FF),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _getAnnouncementColor(announcement).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(ResponsiveUtils.cardRadius),
                ),
                child: Center(
                  child: ResponsiveText(
                    announcement.getIcon(),
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
                            announcement.title,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isRead ? Colors.black87 : Colors.black,
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
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(announcement.priority)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: ResponsiveText(
                            announcement.priority.toUpperCase(),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(announcement.priority),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.spacingS),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getAnnouncementColor(announcement)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: ResponsiveText(
                            announcement.type.toUpperCase(),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getAnnouncementColor(announcement),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            announcement.message,
            fontSize: 14,
            color: Colors.grey[600],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (announcement.scheduleAffected.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.spacingS),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  ResponsiveText(
                    'Affects: ${announcement.scheduleAffected}',
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: ResponsiveUtils.spacingM),
          Row(
            children: [
              ResponsiveText(
                announcement.getTimeAgo(),
                fontSize: 11,
                color: Colors.grey[600],
              ),
              SizedBox(width: ResponsiveUtils.spacingM),
              ResponsiveText(
                'By: ${announcement.author}',
                fontSize: 11,
                color: Colors.grey[600],
              ),
              const Spacer(),
              if (!isRead) ...[
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacingS),
                TextButton(
                  onPressed: () => _markAsRead(announcement),
                  child: Text(
                    'Mark as Read',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getAnnouncementColor(AnnouncementModel announcement) {
    switch (announcement.type) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'maintenance':
        return Colors.yellow;
      case 'general':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.blue;
      case 'medium':
        return Colors.yellow;
      case 'high':
        return Colors.orange;
      case 'critical':
        return Colors.red;
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
            Icons.announcement,
            size: ResponsiveUtils.iconSizeXL * 1.67,
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'No announcements yet',
            fontSize: ResponsiveUtils.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
          SizedBox(height: ResponsiveUtils.spacingM),
          ResponsiveText(
            'You\'ll see announcements here when they are posted',
            fontSize: ResponsiveUtils.fontSizeL,
            color: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showTypeFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Type'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('All Types'),
                    value: 'All',
                    groupValue: selectedFilterType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Info'),
                    value: 'info',
                    groupValue: selectedFilterType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Warning'),
                    value: 'warning',
                    groupValue: selectedFilterType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Urgent'),
                    value: 'urgent',
                    groupValue: selectedFilterType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Maintenance'),
                    value: 'maintenance',
                    groupValue: selectedFilterType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilterType = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('General'),
                    value: 'general',
                    groupValue: selectedFilterType,
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadAnnouncements();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showPriorityFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Priority'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('All Priorities'),
                    value: 'All',
                    groupValue: selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Low'),
                    value: 'low',
                    groupValue: selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Medium'),
                    value: 'medium',
                    groupValue: selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('High'),
                    value: 'high',
                    groupValue: selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Critical'),
                    value: 'critical',
                    groupValue: selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadAnnouncements();
              },
              child: Text('Apply'),
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
    if (selectedPriority != 'All') {
      activeFilters.add(selectedPriority);
    }

    return activeFilters.join(', ');
  }

  void _resetFilters() {
    setState(() {
      selectedFilterType = 'All';
      selectedPriority = 'All';
    });
    _loadAnnouncements();
  }
}
