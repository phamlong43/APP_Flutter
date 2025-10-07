import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserApi {

  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final response = await http.get(
      Uri.parse(ApiConfig.getUserUrl(username)),
      headers: ApiConfig.defaultHeaders,
    ).timeout(ApiConfig.requestTimeout);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> registerUser(String username, String password, {String role = 'user'}) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getRegisterUrl()),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'username': username, 'password': password, 'role': role}),
    ).timeout(ApiConfig.requestTimeout);
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getLoginUrl()),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(ApiConfig.requestTimeout);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(ApiConfig.getUserByIdUrl(id)),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(data),
    ).timeout(ApiConfig.requestTimeout);
    return response.statusCode == 200;
  }
}
