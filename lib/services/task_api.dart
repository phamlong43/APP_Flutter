import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TaskApi {
  static String get baseUrl => '${ApiConfig.tasksEndpoint}/all';

  static Future<List<Map<String, dynamic>>> getAllTasks() async {
    final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getTasksByUsername(String username) async {
    final url = '${ApiConfig.tasksEndpoint}/my?username=$username';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    }
    return [];
  }
}
