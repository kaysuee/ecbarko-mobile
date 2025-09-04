import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Debug Service for API troubleshooting and diagnostics
///
/// This service provides:
/// 1. API endpoint health checking
/// 2. Network connectivity diagnostics
/// 3. Server response analysis
/// 4. Performance monitoring
class DebugService {
  static const String _baseUrl = 'https://ecbarko-db.onrender.com';
  static final List<Map<String, dynamic>> _debugLogs = [];
  static Timer? _healthCheckTimer;

  /// Start debug monitoring
  static void startDebugMonitoring() {
    debugPrint('🔍 Starting debug monitoring');

    // Check API health every 60 seconds
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _performHealthCheck();
    });
  }

  /// Stop debug monitoring
  static void stopDebugMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    debugPrint('⏹️ Debug monitoring stopped');
  }

  /// Perform comprehensive health check
  static Future<void> _performHealthCheck() async {
    try {
      debugPrint('🔍 Performing API health check...');

      // Check basic connectivity
      final connectivity = await _checkConnectivity();
      logDebug('connectivity', 'Basic connectivity check', connectivity);

      // Check API server response
      final apiHealth = await _checkApiHealth();
      logDebug('api_health', 'API server health check', apiHealth);

      // Check specific endpoints
      final endpoints = await _checkEndpoints();
      logDebug('endpoints', 'Endpoint availability check', endpoints);

      // Analyze recent errors
      _analyzeRecentErrors();
    } catch (e) {
      debugPrint('❌ Error during health check: $e');
      logDebug('error', 'Health check failed', {'error': e.toString()});
    }
  }

  /// Check basic network connectivity
  static Future<Map<String, dynamic>> _checkConnectivity() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Test DNS resolution
      final addresses = await InternetAddress.lookup('google.com');
      final dnsTime = stopwatch.elapsedMilliseconds;

      // Test HTTP connectivity
      stopwatch.reset();
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(Uri.parse('https://httpbin.org/get'));
      final response = await request.close();
      final httpTime = stopwatch.elapsedMilliseconds;

      client.close();

      return {
        'dns_resolution': addresses.isNotEmpty,
        'dns_time_ms': dnsTime,
        'http_connectivity': response.statusCode == 200,
        'http_time_ms': httpTime,
        'overall_status': 'healthy',
      };
    } catch (e) {
      return {
        'dns_resolution': false,
        'http_connectivity': false,
        'error': e.toString(),
        'overall_status': 'failed',
      };
    }
  }

  /// Check API server health
  static Future<Map<String, dynamic>> _checkApiHealth() async {
    try {
      final stopwatch = Stopwatch()..start();

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      // Test root endpoint
      final request = await client.getUrl(Uri.parse('$_baseUrl/'));
      final response = await request.close();
      final responseTime = stopwatch.elapsedMilliseconds;

      client.close();

      return {
        'server_reachable': true,
        'response_time_ms': responseTime,
        'status_code': response.statusCode,
        'overall_status': response.statusCode < 500 ? 'healthy' : 'degraded',
      };
    } catch (e) {
      return {
        'server_reachable': false,
        'error': e.toString(),
        'overall_status': 'failed',
      };
    }
  }

  /// Check specific API endpoints
  static Future<Map<String, dynamic>> _checkEndpoints() async {
    final endpoints = [
      '/api/health',
      '/api/login',
      '/api/user',
      '/api/announcement',
    ];

    final results = <String, Map<String, dynamic>>{};

    for (final endpoint in endpoints) {
      try {
        final stopwatch = Stopwatch()..start();

        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);

        final request = await client.getUrl(Uri.parse('$_baseUrl$endpoint'));
        final response = await request.close();
        final responseTime = stopwatch.elapsedMilliseconds;

        client.close();

        results[endpoint] = {
          'status_code': response.statusCode,
          'response_time_ms': responseTime,
          'accessible': response.statusCode < 500,
        };
      } catch (e) {
        results[endpoint] = {
          'status_code': 0,
          'response_time_ms': 0,
          'accessible': false,
          'error': e.toString(),
        };
      }
    }

    return {
      'endpoints': results,
      'accessible_count':
          results.values.where((r) => r['accessible'] == true).length,
      'total_count': results.length,
    };
  }

  /// Analyze recent errors for patterns
  static void _analyzeRecentErrors() {
    if (_debugLogs.isEmpty) return;

    final recentLogs = _debugLogs.where((log) {
      final timestamp = DateTime.parse(log['timestamp']);
      return DateTime.now().difference(timestamp).inMinutes < 10;
    }).toList();

    final errorLogs =
        recentLogs.where((log) => log['type'] == 'error').toList();

    if (errorLogs.isNotEmpty) {
      debugPrint('⚠️ Found ${errorLogs.length} errors in the last 10 minutes');

      // Group errors by type
      final errorGroups = <String, int>{};
      for (final log in errorLogs) {
        final errorType = log['data']['error']?.toString() ?? 'unknown';
        errorGroups[errorType] = (errorGroups[errorType] ?? 0) + 1;
      }

      debugPrint('📊 Error breakdown:');
      errorGroups.forEach((error, count) {
        debugPrint('  - $error: $count occurrences');
      });
    }
  }

  /// Log debug information
  static void logDebug(String type, String message, Map<String, dynamic> data) {
    final log = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'message': message,
      'data': data,
    };

    _debugLogs.add(log);

    // Keep only last 100 logs
    if (_debugLogs.length > 100) {
      _debugLogs.removeAt(0);
    }

    debugPrint('🔍 DEBUG [$type]: $message - ${data.toString()}');
  }

  /// Get debug logs
  static List<Map<String, dynamic>> getDebugLogs() {
    return List.from(_debugLogs);
  }

  /// Get recent error summary
  static Map<String, dynamic> getErrorSummary() {
    final recentLogs = _debugLogs.where((log) {
      final timestamp = DateTime.parse(log['timestamp']);
      return DateTime.now().difference(timestamp).inMinutes < 30;
    }).toList();

    final errorLogs =
        recentLogs.where((log) => log['type'] == 'error').toList();

    return {
      'total_errors': errorLogs.length,
      'recent_errors': errorLogs.take(10).toList(),
      'error_types': _getErrorTypes(errorLogs),
    };
  }

  /// Get error types from logs
  static Map<String, int> _getErrorTypes(List<Map<String, dynamic>> errorLogs) {
    final types = <String, int>{};

    for (final log in errorLogs) {
      final errorType = log['data']['error']?.toString() ?? 'unknown';
      types[errorType] = (types[errorType] ?? 0) + 1;
    }

    return types;
  }

  /// Test specific API endpoint
  static Future<Map<String, dynamic>> testEndpoint(String endpoint) async {
    try {
      final stopwatch = Stopwatch()..start();

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('$_baseUrl$endpoint'));
      final response = await request.close();
      final responseTime = stopwatch.elapsedMilliseconds;

      // Read response body
      String responseBody = '';
      try {
        responseBody = await response.transform(utf8.decoder).join();
      } catch (e) {
        responseBody = 'Error reading response: $e';
      }

      client.close();

      final result = {
        'endpoint': endpoint,
        'status_code': response.statusCode,
        'response_time_ms': responseTime,
        'success': response.statusCode < 500,
        'response_body': responseBody.length > 500
            ? '${responseBody.substring(0, 500)}...'
            : responseBody,
      };

      logDebug('endpoint_test', 'Tested endpoint: $endpoint', result);
      return result;
    } catch (e) {
      final result = {
        'endpoint': endpoint,
        'status_code': 0,
        'response_time_ms': 0,
        'success': false,
        'error': e.toString(),
      };

      logDebug('endpoint_test', 'Failed to test endpoint: $endpoint', result);
      return result;
    }
  }

  /// Clear debug logs
  static void clearLogs() {
    _debugLogs.clear();
    debugPrint('🗑️ Debug logs cleared');
  }

  /// Get system diagnostics
  static Map<String, dynamic> getSystemDiagnostics() {
    return {
      'debug_logs_count': _debugLogs.length,
      'monitoring_active': _healthCheckTimer != null,
      'base_url': _baseUrl,
      'recent_errors': getErrorSummary(),
    };
  }
}
