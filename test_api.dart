import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test các API requests
  await testGetRequest();
  print('\n' + '='*50 + '\n');
  await testPutRequest();
  print('\n' + '='*50 + '\n');
  await testDeleteRequest();
}

Future<void> testGetRequest() async {
  final url = Uri.parse('http://localhost:8080/api/projects');
  
  print('Testing GET request:');
  print('URL: $url');
  print('');

  try {
    final response = await http.get(url);
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        print('✅ SUCCESS: GET request successful');
        print('Projects found: ${data.length}');
        print('First project ID: ${data[0]['id']} (type: ${data[0]['id'].runtimeType})');
      } else {
        print('⚠️ WARNING: No projects found');
      }
    } else {
      print('❌ ERROR: GET request failed');
    }
  } catch (e) {
    print('❌ EXCEPTION: $e');
  }
}

Future<void> testPutRequest() async {
  final url = Uri.parse('http://localhost:8080/api/projects/1');
  final data = {
    "projectName": "Dự án A - cập nhật",
    "description": "Mô tả mới",
    "startDate": "2025-07-01",
    "endDate": "2025-12-31",
    "projectManager": "Nguyen Van B",
    "status": "in_progress"
  };

  print('Testing PUT request:');
  print('URL: $url');
  print('Body: ${jsonEncode(data)}');
  print('');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ SUCCESS: PUT request successful');
    } else {
      print('❌ ERROR: PUT request failed');
    }
  } catch (e) {
    print('❌ EXCEPTION: $e');
  }
}

Future<void> testDeleteRequest() async {
  // Chú ý: Thay ID này bằng ID thực tế từ database
  final url = Uri.parse('http://localhost:8080/api/projects/999'); // ID giả để test
  
  print('Testing DELETE request:');
  print('URL: $url');
  print('');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('✅ SUCCESS: DELETE request successful');
    } else if (response.statusCode == 404) {
      print('⚠️ INFO: Project not found (expected for test ID 999)');
    } else {
      print('❌ ERROR: DELETE request failed');
    }
  } catch (e) {
    print('❌ EXCEPTION: $e');
  }
}
