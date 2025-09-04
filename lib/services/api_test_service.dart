import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// API Test Service for debugging API endpoints
///
/// This service provides:
/// 1. Individual endpoint testing
/// 2. Response format validation
/// 3. Error diagnosis
/// 4. Performance monitoring
class ApiTestService {
  /// Test active bookings endpoint
  static Future<Map<String, dynamic>> testActiveBookings(String userId) async {
    try {
      debugPrint('🧪 Testing active bookings endpoint for user: $userId');

      final stopwatch = Stopwatch()..start();
      final response = await ApiService.get('/api/actbooking/$userId');
      final responseTime = stopwatch.elapsedMilliseconds;

      debugPrint('📊 Response time: ${responseTime}ms');
      debugPrint('📊 Status code: ${response.statusCode}');
      debugPrint('📊 Response body length: ${response.body.length}');

      final data = await ApiService.handleResponse(response);

      return {
        'success': true,
        'responseTime': responseTime,
        'statusCode': response.statusCode,
        'dataType': data.runtimeType.toString(),
        'isList': data is List,
        'isMap': data is Map<String, dynamic>,
        'dataLength': data is List ? (data as List).length : 0,
        'sampleData': data is List && (data as List).isNotEmpty
            ? (data as List).first
            : data,
        'rawResponse': response.body.length > 500
            ? '${response.body.substring(0, 500)}...'
            : response.body,
      };
    } catch (e) {
      debugPrint('❌ Error testing active bookings: $e');
      return {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  /// Test schedules endpoint
  static Future<Map<String, dynamic>> testSchedules() async {
    try {
      debugPrint('🧪 Testing schedules endpoint');

      final stopwatch = Stopwatch()..start();
      final response = await ApiService.get('/api/schedule');
      final responseTime = stopwatch.elapsedMilliseconds;

      debugPrint('📊 Response time: ${responseTime}ms');
      debugPrint('📊 Status code: ${response.statusCode}');
      debugPrint('📊 Response body length: ${response.body.length}');

      final data = await ApiService.handleResponse(response);

      return {
        'success': true,
        'responseTime': responseTime,
        'statusCode': response.statusCode,
        'dataType': data.runtimeType.toString(),
        'isList': data is List,
        'isMap': data is Map<String, dynamic>,
        'dataLength': data is List ? (data as List).length : 0,
        'sampleData': data is List && (data as List).isNotEmpty
            ? (data as List).first
            : data,
        'rawResponse': response.body.length > 500
            ? '${response.body.substring(0, 500)}...'
            : response.body,
      };
    } catch (e) {
      debugPrint('❌ Error testing schedules: $e');
      return {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  /// Test user data endpoint
  static Future<Map<String, dynamic>> testUserData(String userId) async {
    try {
      debugPrint('🧪 Testing user data endpoint for user: $userId');

      final stopwatch = Stopwatch()..start();
      final response = await ApiService.get('/api/user/$userId');
      final responseTime = stopwatch.elapsedMilliseconds;

      debugPrint('📊 Response time: ${responseTime}ms');
      debugPrint('📊 Status code: ${response.statusCode}');
      debugPrint('📊 Response body length: ${response.body.length}');

      final data = await ApiService.handleResponse(response);

      return {
        'success': true,
        'responseTime': responseTime,
        'statusCode': response.statusCode,
        'dataType': data.runtimeType.toString(),
        'isMap': data is Map<String, dynamic>,
        'hasUserId': data is Map<String, dynamic> && data.containsKey('_id'),
        'sampleData': data,
        'rawResponse': response.body.length > 500
            ? '${response.body.substring(0, 500)}...'
            : response.body,
      };
    } catch (e) {
      debugPrint('❌ Error testing user data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  /// Test all dashboard endpoints
  static Future<Map<String, dynamic>> testAllEndpoints(String userId) async {
    debugPrint('🧪 Testing all dashboard endpoints for user: $userId');

    final results = <String, Map<String, dynamic>>{};

    // Test user data
    results['userData'] = await testUserData(userId);

    // Test active bookings
    results['activeBookings'] = await testActiveBookings(userId);

    // Test schedules
    results['schedules'] = await testSchedules();

    // Test card data
    try {
      final stopwatch = Stopwatch()..start();
      final response = await ApiService.get('/api/card/$userId');
      final responseTime = stopwatch.elapsedMilliseconds;
      final data = await ApiService.handleResponse(response);

      results['cardData'] = {
        'success': true,
        'responseTime': responseTime,
        'statusCode': response.statusCode,
        'dataType': data.runtimeType.toString(),
        'isMap': data is Map<String, dynamic>,
        'hasBalance':
            data is Map<String, dynamic> && data.containsKey('balance'),
      };
    } catch (e) {
      results['cardData'] = {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }

    // Test announcements
    try {
      final stopwatch = Stopwatch()..start();
      final response = await ApiService.get('/api/announcement/$userId');
      final responseTime = stopwatch.elapsedMilliseconds;
      final data = await ApiService.handleResponse(response);

      results['announcements'] = {
        'success': true,
        'responseTime': responseTime,
        'statusCode': response.statusCode,
        'dataType': data.runtimeType.toString(),
        'isList': data is List,
        'dataLength': data is List ? (data as List).length : 0,
      };
    } catch (e) {
      results['announcements'] = {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }

    // Summary
    final successCount =
        results.values.where((r) => r['success'] == true).length;
    final totalCount = results.length;

    debugPrint(
        '📊 API Test Summary: $successCount/$totalCount endpoints successful');

    return {
      'summary': {
        'totalEndpoints': totalCount,
        'successfulEndpoints': successCount,
        'failedEndpoints': totalCount - successCount,
        'successRate':
            (successCount / totalCount * 100).toStringAsFixed(1) + '%',
      },
      'results': results,
    };
  }

  /// Get endpoint health status
  static Map<String, String> getEndpointHealth(
      Map<String, dynamic> testResults) {
    final health = <String, String>{};

    for (final entry in testResults.entries) {
      if (entry.key == 'summary') continue;

      final result = entry.value as Map<String, dynamic>;
      if (result['success'] == true) {
        final responseTime = result['responseTime'] as int;
        if (responseTime < 1000) {
          health[entry.key] = '🟢 Healthy (${responseTime}ms)';
        } else if (responseTime < 3000) {
          health[entry.key] = '🟡 Slow (${responseTime}ms)';
        } else {
          health[entry.key] = '🔴 Very Slow (${responseTime}ms)';
        }
      } else {
        health[entry.key] = '❌ Failed (${result['error']})';
      }
    }

    return health;
  }
}
