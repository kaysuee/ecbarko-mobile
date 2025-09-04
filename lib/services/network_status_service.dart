import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Network Status Service for handling network connectivity issues
///
/// This service provides:
/// 1. Network connectivity monitoring
/// 2. API health checking
/// 3. Offline mode detection
/// 4. Network quality assessment
class NetworkStatusService {
  static bool _isOnline = true;
  static bool _isApiHealthy = true;
  static DateTime? _lastSuccessfulRequest;
  static Timer? _healthCheckTimer;

  // Network quality thresholds
  static const Duration _slowResponseThreshold = Duration(seconds: 10);
  static const Duration _timeoutThreshold = Duration(seconds: 30);

  /// Initialize network monitoring
  static void startMonitoring() {
    debugPrint('🌐 Starting network status monitoring');

    // Check network health every 30 seconds
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNetworkHealth();
    });
  }

  /// Stop network monitoring
  static void stopMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    debugPrint('⏹️ Network status monitoring stopped');
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  /// Check API health
  static Future<bool> checkApiHealth() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client
          .getUrl(Uri.parse('https://ecbarko-db.onrender.com/api/health'));
      final response = await request.close();

      _isApiHealthy = response.statusCode == 200;
      if (_isApiHealthy) {
        _lastSuccessfulRequest = DateTime.now();
      }

      client.close();
      return _isApiHealthy;
    } catch (e) {
      debugPrint('❌ API health check failed: $e');
      _isApiHealthy = false;
      return false;
    }
  }

  /// Check network health comprehensively
  static Future<void> _checkNetworkHealth() async {
    try {
      final online = await isOnline();
      final apiHealthy = await checkApiHealth();

      debugPrint(
          '🌐 Network status - Online: $online, API Healthy: $apiHealthy');

      if (!online) {
        debugPrint('⚠️ Device appears to be offline');
      } else if (!apiHealthy) {
        debugPrint('⚠️ API server appears to be down or slow');
      } else {
        debugPrint('✅ Network and API are healthy');
      }
    } catch (e) {
      debugPrint('❌ Error checking network health: $e');
    }
  }

  /// Record successful API request
  static void recordSuccessfulRequest() {
    _lastSuccessfulRequest = DateTime.now();
    _isApiHealthy = true;
  }

  /// Record failed API request
  static void recordFailedRequest() {
    _isApiHealthy = false;
  }

  /// Check if we should use cached data due to network issues
  static bool shouldUseCachedData() {
    if (!_isOnline || !_isApiHealthy) {
      return true;
    }

    // If last successful request was more than 5 minutes ago, prefer cache
    if (_lastSuccessfulRequest != null) {
      final timeSinceLastSuccess =
          DateTime.now().difference(_lastSuccessfulRequest!);
      if (timeSinceLastSuccess > const Duration(minutes: 5)) {
        return true;
      }
    }

    return false;
  }

  /// Get network status information
  static Map<String, dynamic> getNetworkStatus() {
    return {
      'isOnline': _isOnline,
      'isApiHealthy': _isApiHealthy,
      'lastSuccessfulRequest': _lastSuccessfulRequest?.toIso8601String(),
      'shouldUseCachedData': shouldUseCachedData(),
      'timeSinceLastSuccess': _lastSuccessfulRequest != null
          ? DateTime.now().difference(_lastSuccessfulRequest!).inSeconds
          : null,
    };
  }

  /// Check if response time indicates slow network
  static bool isSlowResponse(Duration responseTime) {
    return responseTime > _slowResponseThreshold;
  }

  /// Check if request timed out
  static bool isTimeout(Duration responseTime) {
    return responseTime > _timeoutThreshold;
  }

  /// Get recommended cache duration based on network quality
  static Duration getRecommendedCacheDuration() {
    if (!_isOnline || !_isApiHealthy) {
      return const Duration(hours: 1); // Use longer cache when offline
    }

    if (_lastSuccessfulRequest != null) {
      final timeSinceLastSuccess =
          DateTime.now().difference(_lastSuccessfulRequest!);
      if (timeSinceLastSuccess > const Duration(minutes: 10)) {
        return const Duration(minutes: 30); // Use longer cache when API is slow
      }
    }

    return const Duration(minutes: 10); // Normal cache duration
  }

  /// Force refresh network status
  static Future<void> refreshStatus() async {
    await _checkNetworkHealth();
  }
}
