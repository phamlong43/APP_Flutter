import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  print('🔍 TESTING CONNECTION TO BACKEND SERVER 🔍\n');
  
  // Các URL để test
  final urlsToTest = [
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://10.0.2.2:8080',
    // Thêm IP máy local nếu cần
  ];
  
  for (String baseUrl in urlsToTest) {
    await testConnection(baseUrl);
    print('${'='*60}\n');
  }
  
  // Test network connectivity
  await testGeneralConnectivity();
}

Future<void> testConnection(String baseUrl) async {
  print('📡 Testing: $baseUrl');
  print('Platform: ${Platform.operatingSystem}');
  
  try {
    // Test 1: Health check (nếu có)
    await testHealthCheck(baseUrl);
    
    // Test 2: GET projects
    await testGetProjects(baseUrl);
    
    // Test 3: POST project (if server allows)
    await testCreateProject(baseUrl);
    
  } catch (e) {
    print('❌ Overall test failed: $e');
  }
}

Future<void> testHealthCheck(String baseUrl) async {
  try {
    print('\n🩺 Health Check...');
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: 5));
    
    print('✅ Health check: ${response.statusCode}');
  } catch (e) {
    print('⚠️ Health check failed (có thể server không có health endpoint): $e');
  }
}

Future<void> testGetProjects(String baseUrl) async {
  try {
    print('\n📋 GET /api/projects...');
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects'),
      headers: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        print('✅ GET Projects successful! Found ${data.length} projects');
        if (data.isNotEmpty) {
          print('Sample project: ${data.first}');
        }
      }
    } else {
      print('❌ GET Projects failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('❌ GET Projects error: $e');
  }
}

Future<void> testCreateProject(String baseUrl) async {
  try {
    print('\n➕ POST /api/projects (test create)...');
    final testProject = {
      "projectName": "Test Connection Project",
      "description": "This is a test project to verify API connection",
      "startDate": "2025-01-01",
      "endDate": "2025-12-31",
      "projectManager": "Test Manager",
      "status": "planned"
    };
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(testProject),
    ).timeout(Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ POST Project successful!');
      // Thử xóa project test này nếu tạo thành công
      try {
        final createdData = jsonDecode(response.body);
        if (createdData['id'] != null) {
          await testDeleteProject(baseUrl, createdData['id']);
        }
      } catch (e) {
        print('⚠️ Could not cleanup test project: $e');
      }
    } else {
      print('❌ POST Project failed');
    }
  } catch (e) {
    print('❌ POST Project error: $e');
  }
}

Future<void> testDeleteProject(String baseUrl, dynamic id) async {
  try {
    print('\n🗑️ DELETE /api/projects/$id (cleanup test)...');
    final response = await http.delete(
      Uri.parse('$baseUrl/api/projects/$id'),
      headers: {'Accept': 'application/json'},
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('✅ Test project cleaned up successfully');
    } else {
      print('⚠️ Could not delete test project: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Cleanup failed: $e');
  }
}

Future<void> testGeneralConnectivity() async {
  print('🌐 Testing general internet connectivity...');
  try {
    final response = await http.get(
      Uri.parse('https://www.google.com'),
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      print('✅ Internet connectivity: OK');
    } else {
      print('⚠️ Internet connectivity: Limited');
    }
  } catch (e) {
    print('❌ No internet connectivity: $e');
  }
}
