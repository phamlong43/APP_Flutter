import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskApi {
  static const String baseUrl = 'http://10.0.2.2:8080/tasks/all';

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
}
