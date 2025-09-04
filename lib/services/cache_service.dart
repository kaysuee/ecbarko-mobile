import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'announcement_service.dart';
import 'notification_service.dart';
import 'network_status_service.dart';

/// Centralized Cache Service for Dashboard Data
///
/// This service provides:
/// 1. In-memory caching for frequently accessed data
/// 2. Persistent caching using SharedPreferences
/// 3. Cache invalidation strategies
/// 4. Background refresh capabilities
/// 5. Optimized API call batching
class CacheService {
  static const String _userDataKey = 'cached_user_data';
  static const String _cardDataKey = 'cached_card_data';
  static const String _bookingsKey = 'cached_bookings';
  static const String _announcementsKey = 'cached_announcements';
  static const String _notificationsKey = 'cached_notifications';
  static const String _cacheTimestampKey = 'cache_timestamps';

  // Cache duration constants
  static const Duration _userDataCacheDuration = Duration(minutes: 30);
  static const Duration _cardDataCacheDuration = Duration(minutes: 15);
  static const Duration _bookingsCacheDuration = Duration(minutes: 10);
  static const Duration _announcementsCacheDuration = Duration(minutes: 60);
  static const Duration _notificationsCacheDuration = Duration(minutes: 5);

  // In-memory cache
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// Get cached data with fallback to API
  static Future<T?> getCachedData<T>(
    String key,
    Future<T> Function() apiCall, {
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    try {
      // Check network status and decide whether to use cache
      final shouldUseCache = NetworkStatusService.shouldUseCachedData();
      final isCacheExpired = _isCacheExpired(key, cacheDuration);

      // If network is poor or API is down, prefer cached data
      if (shouldUseCache && !forceRefresh) {
        debugPrint(
            '🌐 Network issues detected, preferring cached data for $key');
        final cachedData = await _getFallbackData<T>(key);
        if (cachedData != null) {
          return cachedData;
        }
      }

      // Check if we should force refresh or if cache is expired
      if (forceRefresh || isCacheExpired) {
        debugPrint('🔄 Cache miss or expired for $key, fetching from API');
        try {
          final data = await _retryApiCall(apiCall);
          await _setCachedData(key, data);
          NetworkStatusService.recordSuccessfulRequest();
          return data;
        } catch (e) {
          debugPrint('❌ API call failed for $key, trying cached data: $e');
          NetworkStatusService.recordFailedRequest();
          // If API fails, try to return cached data as fallback
          return await _getFallbackData<T>(key);
        }
      }

      // Try memory cache first
      if (_memoryCache.containsKey(key)) {
        debugPrint('💾 Cache hit in memory for $key');
        return _memoryCache[key] as T?;
      }

      // Try persistent cache
      final persistentData = await _getPersistentData<T>(key);
      if (persistentData != null) {
        debugPrint('💾 Cache hit in persistent storage for $key');
        _memoryCache[key] = persistentData;
        return persistentData;
      }

      // Fallback to API
      debugPrint('🔄 No cache found for $key, fetching from API');
      try {
        final data = await _retryApiCall(apiCall);
        await _setCachedData(key, data);
        return data;
      } catch (e) {
        debugPrint('❌ API call failed for $key: $e');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting cached data for $key: $e');
      return await _getFallbackData<T>(key);
    }
  }

  /// Retry API call with exponential backoff
  static Future<T> _retryApiCall<T>(Future<T> Function() apiCall) async {
    int retries = 3;
    Duration delay = const Duration(seconds: 1);

    for (int i = 0; i < retries; i++) {
      try {
        return await apiCall();
      } catch (e) {
        if (i == retries - 1) rethrow;

        debugPrint(
            '🔄 API call failed, retrying in ${delay.inSeconds}s (attempt ${i + 1}/$retries): $e');
        await Future.delayed(delay);
        delay = Duration(seconds: delay.inSeconds * 2); // Exponential backoff
      }
    }

    throw Exception('API call failed after $retries attempts');
  }

  /// Get fallback data from cache when API fails
  static Future<T?> _getFallbackData<T>(String key) async {
    try {
      // Try memory cache first
      if (_memoryCache.containsKey(key)) {
        debugPrint('🔄 Using memory cache as fallback for $key');
        return _memoryCache[key] as T?;
      }

      // Try persistent cache
      final persistentData = await _getPersistentData<T>(key);
      if (persistentData != null) {
        debugPrint('🔄 Using persistent cache as fallback for $key');
        _memoryCache[key] = persistentData;
        return persistentData;
      }

      debugPrint('❌ No fallback data available for $key');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting fallback data for $key: $e');
      return null;
    }
  }

  /// Set cached data in both memory and persistent storage
  static Future<void> _setCachedData(String key, dynamic data) async {
    try {
      // Store in memory cache
      _memoryCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();

      // Store in persistent cache
      await _setPersistentData(key, data);

      debugPrint('✅ Data cached successfully for $key');
    } catch (e) {
      debugPrint('❌ Error caching data for $key: $e');
    }
  }

  /// Check if cache is expired
  static bool _isCacheExpired(String key, Duration? cacheDuration) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return true;

    final duration = cacheDuration ?? Duration(minutes: 30);
    return DateTime.now().difference(timestamp) > duration;
  }

  /// Get data from persistent storage
  static Future<T?> _getPersistentData<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;

      final data = jsonDecode(jsonString);
      return data as T?;
    } catch (e) {
      debugPrint('❌ Error reading persistent data for $key: $e');
      return null;
    }
  }

  /// Set data in persistent storage
  static Future<void> _setPersistentData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('❌ Error writing persistent data for $key: $e');
    }
  }

  /// Clear specific cache entry
  static Future<void> clearCache(String key) async {
    try {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);

      debugPrint('🗑️ Cache cleared for $key');
    } catch (e) {
      debugPrint('❌ Error clearing cache for $key: $e');
    }
  }

  /// Clear cache by pattern (useful for user-specific data)
  static Future<void> clearCacheByPattern(String pattern) async {
    try {
      final keysToRemove =
          _memoryCache.keys.where((key) => key.contains(pattern)).toList();

      for (final key in keysToRemove) {
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }

      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final keysToRemoveFromPrefs =
          allKeys.where((key) => key.contains(pattern)).toList();

      for (final key in keysToRemoveFromPrefs) {
        await prefs.remove(key);
      }

      debugPrint(
          '🗑️ Cache cleared for pattern: $pattern (${keysToRemove.length} entries)');
    } catch (e) {
      debugPrint('❌ Error clearing cache by pattern $pattern: $e');
    }
  }

  /// Invalidate cache for specific user
  static Future<void> invalidateUserCache(String userId) async {
    await clearCacheByPattern('_$userId');
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_cardDataKey);
      await prefs.remove(_bookingsKey);
      await prefs.remove(_announcementsKey);
      await prefs.remove(_notificationsKey);
      await prefs.remove(_cacheTimestampKey);

      debugPrint('🗑️ All cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing all cache: $e');
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'cachedKeys': _memoryCache.keys.toList(),
      'timestamps': _cacheTimestamps
          .map((key, value) => MapEntry(key, value.toIso8601String())),
    };
  }
}

/// Dashboard-specific cache methods
class DashboardCache {
  /// Get user data with caching
  static Future<Map<String, dynamic>?> getUserData(String userId,
      {bool forceRefresh = false}) async {
    final result = await CacheService.getCachedData(
      '${CacheService._userDataKey}_$userId',
      () => _fetchUserData(userId),
      cacheDuration: CacheService._userDataCacheDuration,
      forceRefresh: forceRefresh,
    );
    return result as Map<String, dynamic>?;
  }

  /// Get card data with caching
  static Future<Map<String, dynamic>?> getCardData(String userId,
      {bool forceRefresh = false}) async {
    final result = await CacheService.getCachedData(
      '${CacheService._cardDataKey}_$userId',
      () => _fetchCardData(userId),
      cacheDuration: CacheService._cardDataCacheDuration,
      forceRefresh: forceRefresh,
    );
    return result as Map<String, dynamic>?;
  }

  /// Get active bookings with caching
  static Future<List<Map<String, dynamic>>> getActiveBookings(String userId,
      {bool forceRefresh = false}) async {
    final result = await CacheService.getCachedData(
      '${CacheService._bookingsKey}_$userId',
      () => _fetchActiveBookings(userId),
      cacheDuration: CacheService._bookingsCacheDuration,
      forceRefresh: forceRefresh,
    );
    return (result as List<Map<String, dynamic>>?) ?? [];
  }

  /// Get announcements with caching
  static Future<List<Map<String, dynamic>>> getAnnouncements(String userId,
      {bool forceRefresh = false}) async {
    final result = await CacheService.getCachedData(
      '${CacheService._announcementsKey}_$userId',
      () => _fetchAnnouncements(userId),
      cacheDuration: CacheService._announcementsCacheDuration,
      forceRefresh: forceRefresh,
    );
    return (result as List<Map<String, dynamic>>?) ?? [];
  }

  /// Get unread notification count with caching
  static Future<int> getUnreadNotificationCount(String userId,
      {bool forceRefresh = false}) async {
    final result = await CacheService.getCachedData(
      '${CacheService._notificationsKey}_$userId',
      () => _fetchUnreadNotificationCount(userId),
      cacheDuration: CacheService._notificationsCacheDuration,
      forceRefresh: forceRefresh,
    );
    return (result as int?) ?? 0;
  }

  /// Refresh all dashboard data in parallel
  static Future<Map<String, dynamic>> refreshAllData(String userId) async {
    debugPrint('🔄 Refreshing all dashboard data for user: $userId');

    try {
      // Execute all API calls in parallel
      final results = await Future.wait([
        _fetchUserData(userId),
        _fetchCardData(userId),
        _fetchActiveBookings(userId),
        _fetchAnnouncements(userId),
        _fetchUnreadNotificationCount(userId),
      ]);

      // Cache all results
      await Future.wait([
        CacheService._setCachedData(
            '${CacheService._userDataKey}_$userId', results[0]),
        CacheService._setCachedData(
            '${CacheService._cardDataKey}_$userId', results[1]),
        CacheService._setCachedData(
            '${CacheService._bookingsKey}_$userId', results[2]),
        CacheService._setCachedData(
            '${CacheService._announcementsKey}_$userId', results[3]),
        CacheService._setCachedData(
            '${CacheService._notificationsKey}_$userId', results[4]),
      ]);

      debugPrint('✅ All dashboard data refreshed and cached');

      return {
        'userData': results[0] as Map<String, dynamic>?,
        'cardData': results[1] as Map<String, dynamic>?,
        'activeBookings': results[2] as List<Map<String, dynamic>>,
        'announcements': results[3] as List<Map<String, dynamic>>,
        'unreadNotificationCount': results[4] as int,
      };
    } catch (e) {
      debugPrint('❌ Error refreshing dashboard data: $e');
      rethrow;
    }
  }

  /// Preload dashboard data (for background refresh)
  static Future<void> preloadDashboardData(String userId) async {
    try {
      debugPrint('🔄 Preloading dashboard data for user: $userId');
      await refreshAllData(userId);
      debugPrint('✅ Dashboard data preloaded successfully');
    } catch (e) {
      debugPrint('❌ Error preloading dashboard data: $e');
    }
  }

  // Private API call methods
  static Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final response = await ApiService.get('/api/user/$userId');
      return await ApiService.handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error fetching user data: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _fetchCardData(String userId) async {
    try {
      final response = await ApiService.get('/api/card/$userId');
      return await ApiService.handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error fetching card data: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchActiveBookings(
      String userId) async {
    try {
      final response = await ApiService.get('/api/actbooking/$userId');
      final data = await ApiService.handleResponse(response);

      // Handle both array and object responses
      if (data is List) {
        return (data as List).cast<Map<String, dynamic>>();
      } else if (data is Map<String, dynamic> && data.containsKey('bookings')) {
        return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
      } else {
        debugPrint('⚠️ Unexpected response format for active bookings: $data');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching active bookings: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchAnnouncements(
      String userId) async {
    try {
      return await AnnouncementService.getUserAnnouncements(userId: userId);
    } catch (e) {
      debugPrint('❌ Error fetching announcements: $e');
      return [];
    }
  }

  static Future<int> _fetchUnreadNotificationCount(String userId) async {
    try {
      return await NotificationService.getUnreadNotificationCount(
          userId: userId);
    } catch (e) {
      debugPrint('❌ Error fetching unread notification count: $e');
      return 0;
    }
  }
}
