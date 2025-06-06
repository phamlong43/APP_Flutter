import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApi {
  static const String baseUrl = 'http://10.0.2.2:8080/users';

  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/$username')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> registerUser(String username, String password, {String role = 'user'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password, 'role': role}),
    ).timeout(const Duration(seconds: 10));
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 10));
    return response.statusCode == 200;
  }
}
