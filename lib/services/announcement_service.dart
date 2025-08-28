import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class AnnouncementService {
  // Get user announcements
  static Future<List<Map<String, dynamic>>> getUserAnnouncements({
    required String userId,
    String? type,
    String? priority,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for fetching announcements');
        return [];
      }

      // Build query parameters
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (priority != null) queryParams['priority'] = priority;

      final uri = Uri.parse('${getBaseUrl()}/api/announcements/$userId')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> announcements = jsonDecode(response.body);
        return announcements.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch announcements: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // Mark announcement as read
  static Future<void> markAnnouncementAsRead({
    required String announcementId,
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for marking announcement as read');
        return;
      }

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/announcements/$announcementId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Announcement marked as read: $announcementId');
      } else {
        print('Failed to mark announcement as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking announcement as read: $e');
    }
  }

  // Get announcement statistics
  static Future<Map<String, dynamic>?> getAnnouncementStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for fetching announcement stats');
        return null;
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/announcements/stats/overview'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> stats = jsonDecode(response.body);
        return stats;
      } else {
        print('Failed to fetch announcement stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching announcement stats: $e');
      return null;
    }
  }

  // Create new announcement (admin only)
  static Future<void> createAnnouncement({
    required String title,
    required String message,
    required String author,
    String? type,
    String? scheduleAffected,
    String? status,
    List<String>? targetUsers,
    String? priority,
    DateTime? expiresAt,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for creating announcement');
        return;
      }

      final announcementData = {
        'title': title,
        'message': message,
        'author': author,
        'type': type,
        'scheduleAffected': scheduleAffected,
        'status': status,
        'targetUsers': targetUsers,
        'priority': priority,
        'expiresAt': expiresAt?.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/announcements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(announcementData),
      );

      if (response.statusCode == 201) {
        print('Announcement created successfully: $title');
      } else {
        print('Failed to create announcement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating announcement: $e');
    }
  }

  // Update announcement status (admin only)
  static Future<void> updateAnnouncementStatus({
    required String announcementId,
    required String status,
    bool? isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for updating announcement status');
        return;
      }

      final updateData = {
        'status': status,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/announcements/$announcementId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        print('Announcement status updated: $announcementId to $status');
      } else {
        print('Failed to update announcement status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating announcement status: $e');
    }
  }
}
