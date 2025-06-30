import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing PUT request for project update...');
  
  // Các URL để test
  final baseUrls = [
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://10.0.2.2:8080',
  ];
  
  // Data để PUT
  final updateData = {
    "projectName": "Dự án A - cập nhật",
    "description": "Mô tả mới", 
    "startDate": "2025-07-01",
    "endDate": "2025-12-31",
    "projectManager": "Nguyen Van B",
    "status": "in_progress"
  };
  
  String? workingUrl;
  
  // Tìm URL working
  for (String baseUrl in baseUrls) {
    try {
      print('\n🌐 Testing connection to $baseUrl...');
      final testResponse = await http.get(
        Uri.parse('$baseUrl/api/projects'),
      ).timeout(Duration(seconds: 3));
      
      if (testResponse.statusCode == 200 || testResponse.statusCode == 404) {
        workingUrl = baseUrl;
        print('✅ Connection successful to $baseUrl');
        break;
      }
    } catch (e) {
      print('❌ Failed to connect to $baseUrl: $e');
    }
  }
  
  if (workingUrl == null) {
    print('❌ Cannot connect to any backend URL');
    return;
  }
  
  try {
    // 1. Get existing projects để lấy ID
    print('\n📋 Step 1: Getting existing projects...');
    final getResponse = await http.get(
      Uri.parse('$workingUrl/api/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('GET Response Status: ${getResponse.statusCode}');
    
    if (getResponse.statusCode != 200) {
      print('❌ Failed to get projects: ${getResponse.body}');
      return;
    }
    
    final projects = jsonDecode(getResponse.body);
    print('📊 Found ${projects.length} projects');
    
    if (projects.isEmpty) {
      print('⚠️  No projects found. Creating a test project first...');
      
      // Tạo project test trước
      final createData = {
        "projectName": "Dự án A",
        "description": "Mô tả gốc",
        "startDate": "2025-01-01", 
        "endDate": "2025-06-30",
        "projectManager": "Nguyen Van A",
        "status": "planned"
      };
      
      final createResponse = await http.post(
        Uri.parse('$workingUrl/api/projects'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(createData),
      );
      
      print('CREATE Response Status: ${createResponse.statusCode}');
      print('CREATE Response Body: ${createResponse.body}');
      
      if (createResponse.statusCode != 200 && createResponse.statusCode != 201) {
        print('❌ Failed to create test project');
        return;
      }
      
      // Get projects again
      final getResponse2 = await http.get(Uri.parse('$workingUrl/api/projects'));
      final projects2 = jsonDecode(getResponse2.body);
      projects.addAll(projects2);
    }
    
    // Hiển thị projects và chọn project đầu tiên
    print('\n📄 Available projects:');
    for (int i = 0; i < projects.length; i++) {
      final p = projects[i];
      print('  $i: ID=${p['id']} (${p['id'].runtimeType}), Name="${p['projectName']}"');
    }
    
    final targetProject = projects[0];
    final projectId = targetProject['id'];
    
    print('\n🎯 Testing PUT on project: ID=$projectId, Name="${targetProject['projectName']}"');
    
    // 2. Test các methods để kiểm tra backend hỗ trợ gì
    print('\n🔍 Step 2: Testing supported methods...');
    
    final methods = ['OPTIONS', 'PUT', 'PATCH'];
    for (String method in methods) {
      try {
        http.Response? response;
        final uri = Uri.parse('$workingUrl/api/projects/$projectId');
        
        switch (method) {
          case 'OPTIONS':
            response = await http.Request('OPTIONS', uri).send().then((streamedResponse) async {
              return http.Response.fromStream(streamedResponse);
            });
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(updateData),
            );
            break;
          case 'PATCH':
            response = await http.patch(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(updateData),
            );
            break;
        }
        
        print('$method: Status=${response?.statusCode}');
        if (response?.headers.containsKey('allow') == true) {
          print('  Allow header: ${response?.headers['allow']}');
        }
        if (response?.statusCode == 405) {
          print('  ❌ Method Not Allowed');
        } else if ((response?.statusCode ?? 0) < 300) {
          print('  ✅ Success!');
        } else {
          print('  ⚠️  Status: ${response?.statusCode}');
        }
        print('  Response: ${response?.body}');
        print('');
        
      } catch (e) {
        print('$method: Exception - $e');
      }
    }
    
    // 3. Test các endpoint patterns khác nhau
    print('\n🔍 Step 3: Testing different endpoint patterns...');
    
    final endpoints = [
      '$workingUrl/api/projects/$projectId',
      '$workingUrl/api/project/$projectId', // Singular
      '$workingUrl/projects/$projectId',    // No /api
      '$workingUrl/project/$projectId',     // No /api, singular
    ];
    
    for (String endpoint in endpoints) {
      try {
        print('\nTesting PUT to: $endpoint');
        final response = await http.put(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(updateData),
        ).timeout(Duration(seconds: 5));
        
        print('  Status: ${response.statusCode}');
        print('  Body: ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('  ✅ SUCCESS! This endpoint works!');
          break;
        }
        
      } catch (e) {
        print('  ❌ Error: $e');
      }
    }
    
    // 4. Kiểm tra cấu trúc phản hồi
    print('\n📊 Step 4: Analyzing project structure...');
    print('Target project data:');
    targetProject.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });
    
  } catch (e) {
    print('❌ Test failed with exception: $e');
  }
}
