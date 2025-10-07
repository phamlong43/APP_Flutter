import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/services/api_endpoints.dart';

void main() async {
  print('🔍 PROJECT ID STRUCTURE ANALYZER 🔍\n');
  
  final urls = [
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    ApiEndpoints.baseUrl,
  ];
  
  for (String baseUrl in urls) {
    print('Testing: $baseUrl');
    await analyzeProjectStructure(baseUrl);
    print('${'='*60}\n');
  }
}

Future<void> analyzeProjectStructure(String baseUrl) async {
  try {
    // 1. Get all projects
    final response = await http.get(
      Uri.parse('$baseUrl/api/projects'),
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode != 200) {
      print('❌ Failed to get projects: ${response.statusCode}');
      return;
    }
    
    final data = jsonDecode(response.body);
    print('✅ GET /api/projects successful');
    print('Response type: ${data.runtimeType}');
    print('Response: $data\n');
    
    if (data is List && data.isNotEmpty) {
      print('📊 PROJECT STRUCTURE ANALYSIS:');
      print('Total projects: ${data.length}\n');
      
      for (int i = 0; i < data.length; i++) {
        final project = data[i];
        print('--- Project $i ---');
        print('Keys: ${project.keys}');
        print('ID: ${project['id']} (type: ${project['id'].runtimeType})');
        print('Name: ${project['projectName']}');
        print('Full: $project');
        
        // Test specific operations with this ID
        await testProjectOperations(baseUrl, project);
        print('');
      }
    } else {
      print('⚠️ No projects found or invalid response format');
      
      // Try to create a test project
      await createTestProject(baseUrl);
    }
    
  } catch (e) {
    print('❌ Error analyzing projects: $e');
  }
}

Future<void> testProjectOperations(String baseUrl, Map<String, dynamic> project) async {
  final id = project['id'];
  print('🧪 Testing operations with ID: $id (${id.runtimeType})');
  
  // Test GET specific project
  try {
    final getResponse = await http.get(
      Uri.parse('$baseUrl/api/projects/$id'),
    ).timeout(Duration(seconds: 3));
    
    print('  GET /api/projects/$id -> ${getResponse.statusCode}');
    
    if (getResponse.statusCode == 200) {
      final projectData = jsonDecode(getResponse.body);
      print('  ✅ GET individual project successful');
      print('  Retrieved ID: ${projectData['id']} (${projectData['id'].runtimeType})');
    }
  } catch (e) {
    print('  ❌ GET individual project failed: $e');
  }
  
  // Test PUT (update)
  try {
    final updateData = {
      'projectName': project['projectName'] ?? 'Test Project',
      'description': project['description'] ?? 'Test Description', 
      'startDate': project['startDate'] ?? '2025-01-01',
      'endDate': project['endDate'] ?? '2025-12-31',
      'projectManager': project['projectManager'] ?? 'Test Manager',
      'status': project['status'] ?? 'planned',
    };
    
    final putResponse = await http.put(
      Uri.parse('$baseUrl/api/projects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    ).timeout(Duration(seconds: 3));
    
    print('  PUT /api/projects/$id -> ${putResponse.statusCode}');
    
    if (putResponse.statusCode == 200) {
      print('  ✅ PUT successful');
    } else {
      print('  ❌ PUT failed: ${putResponse.body}');
    }
  } catch (e) {
    print('  ❌ PUT failed: $e');
  }
}

Future<void> createTestProject(String baseUrl) async {
  print('🆕 Creating test project to analyze structure...');
  
  final testProject = {
    'projectName': 'Test Project for ID Analysis',
    'description': 'This project is created to analyze ID structure',
    'startDate': '2025-01-01',
    'endDate': '2025-12-31', 
    'projectManager': 'Test Manager',
    'status': 'planned'
  };
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(testProject),
    ).timeout(Duration(seconds: 5));
    
    print('POST /api/projects -> ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final createdProject = jsonDecode(response.body);
      print('✅ Test project created successfully');
      print('Created project: $createdProject');
      print('Generated ID: ${createdProject['id']} (${createdProject['id'].runtimeType})');
      
      // Test operations with the new project
      await testProjectOperations(baseUrl, createdProject);
      
      // Clean up - delete the test project
      try {
        final deleteResponse = await http.delete(
          Uri.parse('$baseUrl/api/projects/${createdProject['id']}'),
        );
        print('🗑️ Cleanup DELETE -> ${deleteResponse.statusCode}');
      } catch (e) {
        print('⚠️ Cleanup failed: $e');
      }
      
    } else {
      print('❌ Failed to create test project: ${response.body}');
    }
  } catch (e) {
    print('❌ Error creating test project: $e');
  }
}
