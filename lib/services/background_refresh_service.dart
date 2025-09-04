import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';

/// Background Refresh Service for Dashboard Data
///
/// This service provides:
/// 1. Periodic background refresh of cached data
/// 2. Smart refresh scheduling based on data importance
/// 3. Battery-optimized refresh intervals
/// 4. User activity-based refresh triggers
class BackgroundRefreshService {
  static Timer? _refreshTimer;
  static bool _isRefreshing = false;

  // Refresh intervals (in minutes)
  static const int _userDataRefreshInterval = 30; // 30 minutes
  static const int _cardDataRefreshInterval = 15; // 15 minutes
  static const int _bookingsRefreshInterval = 10; // 10 minutes
  static const int _announcementsRefreshInterval = 60; // 1 hour
  static const int _notificationsRefreshInterval = 5; // 5 minutes

  // Last refresh timestamps
  static final Map<String, DateTime> _lastRefreshTimes = {};

  /// Start background refresh service
  static void startBackgroundRefresh() {
    if (_refreshTimer != null) {
      debugPrint('🔄 Background refresh already running');
      return;
    }

    debugPrint('🚀 Starting background refresh service');

    // Check every 5 minutes for data that needs refreshing
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performBackgroundRefresh();
    });
  }

  /// Stop background refresh service
  static void stopBackgroundRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint('⏹️ Background refresh service stopped');
  }

  /// Perform background refresh based on data age
  static Future<void> _performBackgroundRefresh() async {
    if (_isRefreshing) {
      debugPrint('⏳ Background refresh already in progress, skipping');
      return;
    }

    try {
      _isRefreshing = true;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userID');

      if (userId == null) {
        debugPrint('❌ No user ID for background refresh');
        return;
      }

      debugPrint('🔄 Performing background refresh for user: $userId');

      // Check which data needs refreshing
      final now = DateTime.now();
      final refreshTasks = <Future<void>>[];

      // Check user data
      if (_shouldRefresh('userData', now, _userDataRefreshInterval)) {
        refreshTasks.add(_refreshUserData(userId));
      }

      // Check card data
      if (_shouldRefresh('cardData', now, _cardDataRefreshInterval)) {
        refreshTasks.add(_refreshCardData(userId));
      }

      // Check bookings
      if (_shouldRefresh('bookings', now, _bookingsRefreshInterval)) {
        refreshTasks.add(_refreshBookings(userId));
      }

      // Check announcements
      if (_shouldRefresh('announcements', now, _announcementsRefreshInterval)) {
        refreshTasks.add(_refreshAnnouncements(userId));
      }

      // Check notifications
      if (_shouldRefresh('notifications', now, _notificationsRefreshInterval)) {
        refreshTasks.add(_refreshNotifications(userId));
      }

      // Execute refresh tasks in parallel
      if (refreshTasks.isNotEmpty) {
        await Future.wait(refreshTasks);
        debugPrint(
            '✅ Background refresh completed (${refreshTasks.length} tasks)');
      } else {
        debugPrint('ℹ️ No data needs refreshing');
      }
    } catch (e) {
      debugPrint('❌ Error during background refresh: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Check if data should be refreshed based on age
  static bool _shouldRefresh(
      String dataType, DateTime now, int intervalMinutes) {
    final lastRefresh = _lastRefreshTimes[dataType];
    if (lastRefresh == null) return true;

    final age = now.difference(lastRefresh);
    return age.inMinutes >= intervalMinutes;
  }

  /// Refresh user data
  static Future<void> _refreshUserData(String userId) async {
    try {
      await DashboardCache.getUserData(userId, forceRefresh: true);
      _lastRefreshTimes['userData'] = DateTime.now();
      debugPrint('✅ User data refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing user data: $e');
    }
  }

  /// Refresh card data
  static Future<void> _refreshCardData(String userId) async {
    try {
      await DashboardCache.getCardData(userId, forceRefresh: true);
      _lastRefreshTimes['cardData'] = DateTime.now();
      debugPrint('✅ Card data refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing card data: $e');
    }
  }

  /// Refresh bookings
  static Future<void> _refreshBookings(String userId) async {
    try {
      await DashboardCache.getActiveBookings(userId, forceRefresh: true);
      _lastRefreshTimes['bookings'] = DateTime.now();
      debugPrint('✅ Bookings refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing bookings: $e');
    }
  }

  /// Refresh announcements
  static Future<void> _refreshAnnouncements(String userId) async {
    try {
      await DashboardCache.getAnnouncements(userId, forceRefresh: true);
      _lastRefreshTimes['announcements'] = DateTime.now();
      debugPrint('✅ Announcements refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing announcements: $e');
    }
  }

  /// Refresh notifications
  static Future<void> _refreshNotifications(String userId) async {
    try {
      await DashboardCache.getUnreadNotificationCount(userId,
          forceRefresh: true);
      _lastRefreshTimes['notifications'] = DateTime.now();
      debugPrint('✅ Notifications refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing notifications: $e');
    }
  }

  /// Force refresh all data (for user-triggered refresh)
  static Future<void> forceRefreshAll(String userId) async {
    debugPrint('🔄 Force refreshing all data for user: $userId');

    try {
      await DashboardCache.refreshAllData(userId);

      // Update all refresh timestamps
      final now = DateTime.now();
      _lastRefreshTimes['userData'] = now;
      _lastRefreshTimes['cardData'] = now;
      _lastRefreshTimes['bookings'] = now;
      _lastRefreshTimes['announcements'] = now;
      _lastRefreshTimes['notifications'] = now;

      debugPrint('✅ Force refresh completed');
    } catch (e) {
      debugPrint('❌ Error during force refresh: $e');
    }
  }

  /// Get refresh status
  static Map<String, dynamic> getRefreshStatus() {
    final now = DateTime.now();
    return {
      'isRunning': _refreshTimer != null,
      'isRefreshing': _isRefreshing,
      'lastRefreshTimes': _lastRefreshTimes.map((key, value) => MapEntry(key, {
            'timestamp': value.toIso8601String(),
            'ageMinutes': now.difference(value).inMinutes,
          })),
    };
  }
}
