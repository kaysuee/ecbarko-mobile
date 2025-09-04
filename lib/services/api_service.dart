import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Centralized API Service for EcBarko App
///
/// This service provides:
/// 1. Centralized HTTP client configuration
/// 2. Automatic token management
/// 3. Consistent error handling
/// 4. Request/response logging
/// 5. Retry mechanisms
class ApiService {
  static const String _baseUrl = 'https://ecbarko-db.onrender.com';
  static const Duration _timeout = Duration(seconds: 15); // Reduced timeout

  // HTTP client with timeout
  static final http.Client _client = http.Client();

  /// Get base URL
  static String get baseUrl => _baseUrl;

  /// Get authorization headers
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// GET request with retry mechanism
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = true,
    int maxRetries = 2,
  }) async {
    return await _retryRequest(
      () => _performGet(endpoint, queryParams, requireAuth),
      'GET',
      endpoint,
      maxRetries,
    );
  }

  /// Perform GET request
  static Future<http.Response> _performGet(
    String endpoint,
    Map<String, String>? queryParams,
    bool requireAuth,
  ) async {
    final uri = _buildUri(endpoint, queryParams);
    final headers = requireAuth
        ? await _getHeaders()
        : {'Content-Type': 'application/json'};

    _logRequest('GET', uri, headers, null);

    final response = await _client.get(uri, headers: headers).timeout(_timeout);

    _logResponse(response);
    return response;
  }

  /// POST request with retry mechanism
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
    int maxRetries = 2,
  }) async {
    return await _retryRequest(
      () => _performPost(endpoint, body, requireAuth),
      'POST',
      endpoint,
      maxRetries,
    );
  }

  /// Perform POST request
  static Future<http.Response> _performPost(
    String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth,
  ) async {
    final uri = _buildUri(endpoint);
    final headers = requireAuth
        ? await _getHeaders()
        : {'Content-Type': 'application/json'};
    final jsonBody = body != null ? jsonEncode(body) : null;

    _logRequest('POST', uri, headers, jsonBody);

    final response = await _client
        .post(uri, headers: headers, body: jsonBody)
        .timeout(_timeout);

    _logResponse(response);
    return response;
  }

  /// PUT request with retry mechanism
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
    int maxRetries = 2,
  }) async {
    return await _retryRequest(
      () => _performPut(endpoint, body, requireAuth),
      'PUT',
      endpoint,
      maxRetries,
    );
  }

  /// Perform PUT request
  static Future<http.Response> _performPut(
    String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth,
  ) async {
    final uri = _buildUri(endpoint);
    final headers = requireAuth
        ? await _getHeaders()
        : {'Content-Type': 'application/json'};
    final jsonBody = body != null ? jsonEncode(body) : null;

    _logRequest('PUT', uri, headers, jsonBody);

    final response = await _client
        .put(uri, headers: headers, body: jsonBody)
        .timeout(_timeout);

    _logResponse(response);
    return response;
  }

  /// DELETE request with retry mechanism
  static Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = true,
    int maxRetries = 2,
  }) async {
    return await _retryRequest(
      () => _performDelete(endpoint, requireAuth),
      'DELETE',
      endpoint,
      maxRetries,
    );
  }

  /// Perform DELETE request
  static Future<http.Response> _performDelete(
    String endpoint,
    bool requireAuth,
  ) async {
    final uri = _buildUri(endpoint);
    final headers = requireAuth
        ? await _getHeaders()
        : {'Content-Type': 'application/json'};

    _logRequest('DELETE', uri, headers, null);

    final response =
        await _client.delete(uri, headers: headers).timeout(_timeout);

    _logResponse(response);
    return response;
  }

  /// Retry mechanism for API requests
  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() request,
    String method,
    String endpoint,
    int maxRetries,
  ) async {
    int attempts = 0;
    Duration delay = const Duration(seconds: 1);

    while (attempts < maxRetries) {
      try {
        attempts++;
        debugPrint('🔄 API $method $endpoint - Attempt $attempts/$maxRetries');

        final response = await request();

        // Check if response indicates server issues
        if (response.statusCode >= 500) {
          throw Exception('Server error: ${response.statusCode}');
        }

        debugPrint('✅ API $method $endpoint - Success on attempt $attempts');
        return response;
      } catch (e) {
        debugPrint('❌ API $method $endpoint - Attempt $attempts failed: $e');

        if (attempts >= maxRetries) {
          debugPrint(
              '💥 API $method $endpoint - All $maxRetries attempts failed');
          rethrow;
        }

        // Wait before retry with exponential backoff
        debugPrint(
            '⏳ API $method $endpoint - Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay = Duration(seconds: delay.inSeconds * 2);
      }
    }

    throw Exception('API request failed after $maxRetries attempts');
  }

  /// Build URI with query parameters
  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  /// Handle API response with error checking
  static Future<Map<String, dynamic>> handleResponse(
    http.Response response, {
    bool showErrorDialog = true,
  }) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }
    } else {
      final error = _parseErrorResponse(response);
      throw ApiException(
        statusCode: response.statusCode,
        message: error['message'] ?? 'Request failed',
        details: error,
      );
    }
  }

  /// Parse error response
  static Map<String, dynamic> _parseErrorResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'message': 'Request failed with status ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    }
  }

  /// Log request details
  static void _logRequest(
      String method, Uri uri, Map<String, String> headers, String? body) {
    debugPrint('🌐 API Request: $method $uri');
    debugPrint('📋 Headers: $headers');
    if (body != null) {
      debugPrint('📦 Body: $body');
    }
  }

  /// Log response details
  static void _logResponse(http.Response response) {
    debugPrint(
        '📥 API Response: ${response.statusCode} ${response.request?.url}');
    if (response.statusCode >= 400) {
      debugPrint('❌ Error Response: ${response.body}');
    }
  }

  /// Log error details
  static void _logError(String method, String endpoint, dynamic error) {
    debugPrint('💥 API Error: $method $endpoint - $error');
  }

  /// Close HTTP client
  static void close() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> details;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.details,
  });

  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }
}

/// Authentication API methods
class AuthApi {
  static const String _loginEndpoint = '/api/login';
  static const String _registerEndpoint = '/api/register';
  static const String _sendOtpEndpoint = '/api/send-otp';
  static const String _verifyOtpEndpoint = '/api/verify-otp';
  static const String _forgotPasswordEndpoint = '/api/forgot-password';
  static const String _resetPasswordEndpoint = '/api/reset-password';

  /// Login user
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await ApiService.post(
      _loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );

    return await ApiService.handleResponse(response);
  }

  /// Register user
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await ApiService.post(
      _registerEndpoint,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
      requireAuth: false,
    );

    return await ApiService.handleResponse(response);
  }

  /// Send OTP
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final response = await ApiService.post(
      _sendOtpEndpoint,
      body: {'email': email},
      requireAuth: false,
    );

    return await ApiService.handleResponse(response);
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final response = await ApiService.post(
      _verifyOtpEndpoint,
      body: {
        'email': email,
        'otp': otp,
      },
      requireAuth: false,
    );

    return await ApiService.handleResponse(response);
  }

  /// Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiService.post(
      _forgotPasswordEndpoint,
      body: {'email': email},
      requireAuth: false,
    );

    return await ApiService.handleResponse(response);
  }

  /// Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      _resetPasswordEndpoint,
      body: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
      requireAuth: false,
    );

    return await ApiService.handleResponse(response);
  }
}

/// Booking API methods
class BookingApi {
  static const String _eticketEndpoint = '/api/eticket';
  static const String _activeBookingsEndpoint = '/api/activebooking';
  static const String _completedBookingsEndpoint = '/api/completedbooking';
  static const String _updateBookingEndpoint = '/api/updatebooking';

  /// Create booking
  static Future<Map<String, dynamic>> createBooking({
    required String email,
    required String user,
    required List<Map<String, dynamic>> passengers,
    required String departureLocation,
    required String arrivalLocation,
    required String departDate,
    required String departTime,
    required String arriveDate,
    required String arriveTime,
    required String shippingLine,
    required bool hasVehicle,
    required String selectedCardType,
    required List<Map<String, dynamic>> vehicleDetail,
    required String bookingReference,
    required double totalFare,
    required String schedcde,
  }) async {
    final response = await ApiService.post(
      _eticketEndpoint,
      body: {
        'email': email,
        'user': user,
        'passengers': passengers,
        'departureLocation': departureLocation,
        'arrivalLocation': arrivalLocation,
        'departDate': departDate,
        'departTime': departTime,
        'arriveDate': arriveDate,
        'arriveTime': arriveTime,
        'shippingLine': shippingLine,
        'hasVehicle': hasVehicle,
        'selectedCardType': selectedCardType,
        'vehicleDetail': vehicleDetail,
        'bookingReference': bookingReference,
        'totalFare': totalFare,
        'schedcde': schedcde,
      },
    );

    return await ApiService.handleResponse(response);
  }

  /// Get active bookings
  static Future<List<Map<String, dynamic>>> getActiveBookings(
      String userId) async {
    final response = await ApiService.get('$_activeBookingsEndpoint/$userId');
    final data = await ApiService.handleResponse(response);
    return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
  }

  /// Get completed bookings
  static Future<List<Map<String, dynamic>>> getCompletedBookings(
      String userId) async {
    final response =
        await ApiService.get('$_completedBookingsEndpoint/$userId');
    final data = await ApiService.handleResponse(response);
    return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
  }

  /// Update booking status
  static Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final response = await ApiService.put(
      '$_updateBookingEndpoint/$bookingId',
      body: {'status': status},
    );

    return await ApiService.handleResponse(response);
  }
}

/// User API methods
class UserApi {
  static const String _userEndpoint = '/api/user';
  static const String _updatePasswordEndpoint = '/api/updatepassword';

  /// Get user data
  static Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await ApiService.get('$_userEndpoint/$userId');
    return await ApiService.handleResponse(response);
  }

  /// Update user password
  static Future<Map<String, dynamic>> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      '$_updatePasswordEndpoint/$userId',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    return await ApiService.handleResponse(response);
  }
}

/// Card API methods
class CardApi {
  static const String _cardEndpoint = '/api/card';
  static const String _cardHistoryEndpoint = '/api/cardhistory';
  static const String _buyLoadEndpoint = '/api/buyload';

  /// Get user card
  static Future<Map<String, dynamic>> getUserCard(String userId) async {
    final response = await ApiService.get('$_cardEndpoint/$userId');
    return await ApiService.handleResponse(response);
  }

  /// Get card history
  static Future<List<Map<String, dynamic>>> getCardHistory(
      String userId) async {
    final response = await ApiService.get('$_cardHistoryEndpoint/$userId');
    final data = await ApiService.handleResponse(response);
    return List<Map<String, dynamic>>.from(data['transactions'] ?? []);
  }

  /// Buy load
  static Future<Map<String, dynamic>> buyLoad({
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await ApiService.post(
      _buyLoadEndpoint,
      body: {
        'userId': userId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
    );

    return await ApiService.handleResponse(response);
  }
}

/// Schedule API methods
class ScheduleApi {
  static const String _scheduleEndpoint = '/api/schedule';

  /// Get schedules
  static Future<List<Map<String, dynamic>>> getSchedules({
    String? departureLocation,
    String? arrivalLocation,
    String? date,
  }) async {
    final queryParams = <String, String>{};
    if (departureLocation != null) queryParams['departure'] = departureLocation;
    if (arrivalLocation != null) queryParams['arrival'] = arrivalLocation;
    if (date != null) queryParams['date'] = date;

    final response = await ApiService.get(
      _scheduleEndpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = await ApiService.handleResponse(response);
    return List<Map<String, dynamic>>.from(data['schedules'] ?? []);
  }
}

/// Announcement API methods
class AnnouncementApi {
  static const String _announcementEndpoint = '/api/announcement';

  /// Get announcements
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await ApiService.get(_announcementEndpoint);
    final data = await ApiService.handleResponse(response);
    return List<Map<String, dynamic>>.from(data['announcements'] ?? []);
  }

  /// Mark announcement as read
  static Future<Map<String, dynamic>> markAsRead(String announcementId) async {
    final response = await ApiService.put(
      '$_announcementEndpoint/$announcementId/read',
    );

    return await ApiService.handleResponse(response);
  }
}

/// Notification API methods
class NotificationApi {
  static const String _notificationEndpoint = '/api/notification';

  /// Get notifications
  static Future<List<Map<String, dynamic>>> getNotifications(
      String userId) async {
    final response = await ApiService.get('$_notificationEndpoint/$userId');
    final data = await ApiService.handleResponse(response);
    return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
  }

  /// Mark notification as read
  static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final response = await ApiService.put(
      '$_notificationEndpoint/$notificationId/read',
    );

    return await ApiService.handleResponse(response);
  }

  /// Get unread count
  static Future<int> getUnreadCount(String userId) async {
    final response =
        await ApiService.get('$_notificationEndpoint/$userId/unread-count');
    final data = await ApiService.handleResponse(response);
    return data['count'] ?? 0;
  }
}
