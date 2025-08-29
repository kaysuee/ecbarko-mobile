import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class AboutService {
  // Get about text from database
  static Future<Map<String, dynamic>?> getAboutText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/about'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> aboutData = jsonDecode(response.body);
        return aboutData;
      } else {
        print('Failed to fetch about text: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching about text: $e');
      return null;
    }
  }

  // Update about text (admin only)
  static Future<bool> updateAboutText({
    required String aboutText,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for updating about text');
        return false;
      }

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/about'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'aboutText': aboutText,
        }),
      );

      if (response.statusCode == 200) {
        print('About text updated successfully');
        return true;
      } else {
        print('Failed to update about text: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating about text: $e');
      return false;
    }
  }
}
