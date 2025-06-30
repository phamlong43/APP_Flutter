import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing different HTTP methods for project update...');
  
  final baseUrl = 'http://localhost:8080';
  
  try {
    // 1. GET projects to find existing project
    print('\n1️⃣ Getting existing projects...');
    final getResponse = await http.get(Uri.parse('$baseUrl/api/projects'));
    
    if (getResponse.statusCode != 200) {
      print('❌ Failed to get projects: ${getResponse.statusCode}');
      return;
    }
    
    final projects = jsonDecode(getResponse.body) as List;
    print('✅ Found ${projects.length} projects');
    
    if (projects.isEmpty) {
      print('⚠️ No projects found to test update');
      return;
    }
    
    final testProject = projects.first;
    final projectId = testProject['id'];
    print('🎯 Testing with project ID: $projectId');
    print('📋 Project name: ${testProject['projectName']}');
    
    // 2. Test data to update
    final updateData = {
      "projectName": "Dự án A - cập nhật",
      "description": "Mô tả mới",
      "startDate": "2025-07-01",
      "endDate": "2025-12-31",
      "projectManager": "Nguyen Van B",
      "status": "in_progress"
    };
    
    print('\n📦 Update data: ${jsonEncode(updateData)}');
    
    // 3. Test different HTTP methods
    final methodsToTest = ['PUT', 'PATCH', 'POST'];
    
    for (String method in methodsToTest) {
      print('\n${'='*50}');
      print('🧪 Testing $method method...');
      print('${'='*50}');
      
      try {
        final url = Uri.parse('$baseUrl/api/projects/$projectId');
        print('🌐 URL: $url');
        
        http.Response? response;
        
        switch (method) {
          case 'PUT':
            response = await http.put(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(updateData),
            ).timeout(Duration(seconds: 10));
            break;
            
          case 'PATCH':
            response = await http.patch(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(updateData),
            ).timeout(Duration(seconds: 10));
            break;
            
          case 'POST':
            response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(updateData),
            ).timeout(Duration(seconds: 10));
            break;
        }
        
        if (response != null) {
          print('📊 Response Status: ${response.statusCode}');
          print('📄 Response Headers: ${response.headers}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            print('✅ SUCCESS! $method method works!');
            print('📝 Response: ${response.body}');
            
            // Verify the update worked by getting the project again
            final verifyResponse = await http.get(Uri.parse('$baseUrl/api/projects/$projectId'));
            if (verifyResponse.statusCode == 200) {
              final updatedProject = jsonDecode(verifyResponse.body);
              print('🔍 Verification - Updated project: ${updatedProject['projectName']}');
              print('🔍 Verification - Status: ${updatedProject['status']}');
            }
            
            break; // Found working method, stop testing
          } else if (response.statusCode == 405) {
            print('❌ Method Not Allowed (405)');
            print('📝 Response: ${response.body}');
          } else if (response.statusCode == 404) {
            print('❌ Not Found (404) - Project might not exist');
            print('📝 Response: ${response.body}');
          } else {
            print('⚠️ Unexpected Status: ${response.statusCode}');
            print('📝 Response: ${response.body}');
          }
        }
        
      } catch (e) {
        print('❌ Exception testing $method: $e');
      }
    }
    
    print('\n${'='*50}');
    print('🏁 Test completed!');
    print('${'='*50}');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
