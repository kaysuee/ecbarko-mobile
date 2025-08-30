import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/announcement_service.dart';
import '../services/about_service.dart';
import '../models/announcement_model.dart';
import '../utils/date_format.dart';

const Color Ec_PRIMARY = Color(0xFF013986);

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<AnnouncementModel> announcements = [];
  String? aboutText;
  DateTime? lastUpdated;
  bool isLoading = true;
  bool hasError = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');

      // Load announcements and about text in parallel
      final results = await Future.wait([
        AnnouncementService.getUserAnnouncements(userId: userId ?? ''),
        AboutService.getAboutText(),
      ]);

      if (mounted) {
        setState(() {
          announcements = (results[0] as List<Map<String, dynamic>>)
              .map((json) => AnnouncementModel.fromJson(json))
              .toList();
          aboutText =
              (results[1] as Map<String, dynamic>?)?['aboutText'] as String?;
          lastUpdated =
              (results[1] as Map<String, dynamic>?)?['updatedAt'] != null
                  ? DateTime.parse(
                      (results[1] as Map<String, dynamic>?)!['updatedAt'])
                  : null;
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image (top half)
          Positioned(
            top: topPadding + 20,
            left: 0,
            right: 0,
            height: screenHeight * 0.5,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/aboutBg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Custom AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: topPadding),
              height: kToolbarHeight + topPadding,
              color: Ec_PRIMARY,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'About App',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Blue card with dynamic content (bottom half)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Ec_PRIMARY,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: Colors.white,
                backgroundColor: Ec_PRIMARY,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60), // for overlapping icon

                      // App Description
                      Text(
                        aboutText ??
                            'ECBARKO is a mobile application designed to enhance the convenience and efficiency of sea travel for passengers and ferry operators alike. '
                                'With a user-friendly interface, the app allows travelers to browse updated ferry schedules, secure reservations, and receive instant notifications on trip changes or delays. '
                                'ECBARKO also offers helpful travel tips, terminal information, and digital ticketing features to eliminate long queues and paperwork. '
                                'By integrating modern technology into maritime travel, ECBARKO brings safety, transparency, and ease right to your fingertips—ensuring that every journey is smooth, timely, and stress-free.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),

                      // Last updated timestamp
                      if (lastUpdated != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.update,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Last updated: ${_formatDate(lastUpdated!)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Recent Announcements
                      if (announcements.isNotEmpty)
                        _buildAnnouncementsSection(),

                      const SizedBox(height: 20),

                      // Loading indicator
                      if (isLoading)
                        const CircularProgressIndicator(color: Colors.white),

                      // Error state
                      if (hasError) _buildErrorState(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Overlapping circular logo
          Positioned(
            bottom: screenHeight * 0.5 - 75,
            left: (screenWidth / 2) - 75,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/aboutLogo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    final recentAnnouncements =
        announcements.where((a) => a.isActive && !a.isExpired).take(3).toList();

    if (recentAnnouncements.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Updates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recentAnnouncements
              .map((announcement) => _buildAnnouncementItem(announcement)),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(AnnouncementModel announcement) {
    return GestureDetector(
      onTap: () => _showAnnouncementDetails(announcement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getAnnouncementColor(announcement.type),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _getAnnouncementColor(announcement.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getAnnouncementIcon(announcement.type),
                color: _getAnnouncementColor(announcement.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    announcement.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    announcement.getTimeAgo(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (announcement.isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getAnnouncementColor(String type) {
    switch (type) {
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

  IconData _getAnnouncementIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'urgent':
        return Icons.priority_high;
      case 'maintenance':
        return Icons.build;
      case 'general':
        return Icons.announcement;
      default:
        return Icons.announcement;
    }
  }

  void _showAnnouncementDetails(AnnouncementModel announcement) {
    // Mark announcement as read if user ID is available
    if (userId != null && !announcement.isReadBy(userId!)) {
      AnnouncementService.markAnnouncementAsRead(
        announcementId: announcement.id,
        userId: userId!,
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Ec_PRIMARY,
          title: Row(
            children: [
              Icon(
                _getAnnouncementIcon(announcement.type),
                color: _getAnnouncementColor(announcement.type),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  announcement.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'By: ${announcement.author}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement.getTimeAgo(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (announcement.scheduleAffected.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Affects: ${announcement.scheduleAffected}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Connection Error',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load data from the server. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateFormatUtil.getCurrentTime();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
