import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testAllEndpoints();
}

Future<void> testAllEndpoints() async {
  final baseUrl = 'http://localhost:8080';
  
  print('🔍 Testing API endpoints...');
  
  // Test GET /api/projects
  await testEndpoint('GET', '$baseUrl/api/projects');
  
  // Test POST /api/projects  
  await testEndpoint('POST', '$baseUrl/api/projects', {
    'projectName': 'Test Project',
    'description': 'Test Description',
    'startDate': '2025-01-01',
    'endDate': '2025-12-31',
    'projectManager': 'Test Manager',
    'status': 'planned',
  });
  
  // Test PUT /api/projects/1 (giả sử có project với ID 1)
  await testEndpoint('PUT', '$baseUrl/api/projects/1', {
    'projectName': 'Updated Test Project',
    'description': 'Updated Description',
    'startDate': '2025-01-01',
    'endDate': '2025-12-31',
    'projectManager': 'Updated Manager',
    'status': 'in_progress',
  });
  
  // Test PATCH /api/projects/1 (thử method khác)
  await testEndpoint('PATCH', '$baseUrl/api/projects/1', {
    'status': 'completed',
  });
  
  // Test DELETE /api/projects/1
  await testEndpoint('DELETE', '$baseUrl/api/projects/1');
  
  print('\n✅ Endpoint testing completed!');
}

Future<void> testEndpoint(String method, String url, [Map<String, dynamic>? body]) async {
  try {
    print('\n📤 Testing: $method $url');
    if (body != null) {
      print('   Body: ${jsonEncode(body)}');
    }
    
    final uri = Uri.parse(url);
    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri);
        break;
      default:
        print('❌ Unsupported method: $method');
        return;
    }
    
    print('📥 Response: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('   Error: ${response.body}');
    } else {
      print('   Success: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');
    }
    
  } catch (e) {
    print('❌ Exception: $e');
  }
}
