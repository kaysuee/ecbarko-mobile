import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // static const String baseUrl = 'http://10.0.2.2:5000';

  static const String baseUrl = 'https://ecbarko.onrender.com';

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid email or password');
    }
  }

  // REGISTER
  static Future<void> register({
    required String email,
    required String password,
    required String name,
    required String profileImageUrl,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'profileImageUrl': profileImageUrl,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 409) {
      throw Exception('User already exists');
    } else {
      throw Exception('Registration failed');
    }
  }
}
