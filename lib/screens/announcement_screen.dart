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
      final currentUserId = prefs.getString('userID');

      if (currentUserId != null) {
        setState(() {
          userId = currentUserId;
        });

        final announcementsData = await AnnouncementService.getUserAnnouncements(
          userId: currentUserId,
        );

        final List<AnnouncementModel> loadedAnnouncements = announcementsData
            .map((json) => AnnouncementModel.fromJson(json))
            .toList();

        // Sort by priority and creation date (highest priority first, then newest)
        loadedAnnouncements.sort((a, b) {
          final priorityOrder = {'critical': 4, 'high': 3, 'medium': 2, 'low': 1};
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

    // Filter by type
    if (selectedFilterType != 'All') {
      filtered = filtered.where((a) => a.type == selectedFilterType.toLowerCase()).toList();
    }

    // Filter by priority
    if (selectedPriority != 'All') {
      filtered = filtered.where((a) => a.priority == selectedPriority.toLowerCase()).toList();
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
            // Announcement Summary Section
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Ec_DARK_PRIMARY.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
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
                          'Total Announcements',
                          fontSize: ResponsiveUtils.fontSizeS,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: ResponsiveUtils.spacingS),
                        ResponsiveText(
                          '${announcements.length}',
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
                          '${announcements.where((a) => !a.isReadBy(userId ?? '')).length}',
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
                          announcements.isNotEmpty 
                              ? announcements.first.getTimeAgo()
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
            
            // Filter Section
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
                  ResponsiveText(
                    'Filter Announcements',
                    fontSize: ResponsiveUtils.fontSizeL,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  SizedBox(height: ResponsiveUtils.spacingM),
                  Row(
                    children: [
                      // Type Filter
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Ec_DARK_PRIMARY.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedFilterType,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: Ec_DARK_PRIMARY),
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: ResponsiveUtils.fontSizeS,
                              ),
                              items: [
                                DropdownMenuItem(value: 'All', child: Text('All Types')),
                                DropdownMenuItem(value: 'info', child: Text('Info')),
                                DropdownMenuItem(value: 'warning', child: Text('Warning')),
                                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                                DropdownMenuItem(value: 'general', child: Text('General')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedFilterType = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacingM),
                      // Priority Filter
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Ec_DARK_PRIMARY.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPriority,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: Ec_DARK_PRIMARY),
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: ResponsiveUtils.fontSizeS,
                              ),
                              items: [
                                DropdownMenuItem(value: 'All', child: Text('All Priorities')),
                                DropdownMenuItem(value: 'low', child: Text('Low')),
                                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                DropdownMenuItem(value: 'high', child: Text('High')),
                                DropdownMenuItem(value: 'critical', child: Text('Critical')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedPriority = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
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
                            color: _getPriorityColor(announcement.priority).withOpacity(0.1),
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
                            color: _getAnnouncementColor(announcement).withOpacity(0.1),
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
}
