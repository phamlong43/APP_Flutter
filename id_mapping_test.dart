/// Test ID mapping system cho WorkScreen
/// Chạy để kiểm tra ID được lưu và sử dụng đúng cách
void main() async {
  await testIdMapping();
}

Future<void> testIdMapping() async {
  print('🧪 Testing ID Mapping System');
  print('=' * 50);
  
  // Mock dữ liệu project giống từ backend
  final List<Map<String, dynamic>> mockProjects = [
    {
      'id': 1, // int ID
      'projectName': 'Project Alpha',
      'description': 'Test project 1',
      'status': 'planned'
    },
    {
      'id': '2', // string ID
      'projectName': 'Project Beta',
      'description': 'Test project 2',
      'status': 'in_progress'
    },
    {
      'id': 'abc123', // string non-numeric ID
      'projectName': 'Project Gamma',
      'description': 'Test project 3',
      'status': 'completed'
    }
  ];
  
  print('📦 Mock projects loaded: ${mockProjects.length}');
  
  // Simulate ID mapping build
  Map<String, dynamic> projectIdMap = {};
  
  for (int i = 0; i < mockProjects.length; i++) {
    final project = mockProjects[i];
    print('\n🔍 Processing project $i:');
    print('   - Name: ${project['projectName']}');
    print('   - ID: ${project['id']} (type: ${project['id'].runtimeType})');
    
    // Build key và parse ID
    final key = '${project['projectName']}-${project['id']}';
    final parsedId = _parseId(project['id']);
    
    projectIdMap[key] = parsedId;
    
    print('   - Key: "$key"');
    print('   - Mapped ID: $parsedId (type: ${parsedId.runtimeType})');
    print('   ✅ Added to mapping');
  }
  
  print('\n📋 ID Mapping Summary:');
  projectIdMap.forEach((key, id) {
    print('   "$key" -> $id (${id.runtimeType})');
  });
  
  print('\n🔧 Testing retrieval:');
  for (final project in mockProjects) {
    final key = '${project['projectName']}-${project['id']}';
    final retrievedId = projectIdMap[key];
    
    print('   🔍 Project: ${project['projectName']}');
    print('      Original: ${project['id']} (${project['id'].runtimeType})');
    print('      Retrieved: $retrievedId (${retrievedId?.runtimeType})');
    print('      Status: ${retrievedId != null ? '✅ Found' : '❌ Missing'}');
  }
  
  print('\n🎯 Testing URL building:');
  const baseUrl = 'http://localhost:8080';
  for (final project in mockProjects) {
    final key = '${project['projectName']}-${project['id']}';
    final id = projectIdMap[key];
    
    if (id != null) {
      final putUrl = '$baseUrl/api/projects/$id';
      final deleteUrl = '$baseUrl/api/projects/$id';
      
      print('   📝 ${project['projectName']}:');
      print('      PUT URL: $putUrl');
      print('      DELETE URL: $deleteUrl');
    }
  }
  
  print('\n✅ ID Mapping test completed!');
}

// Helper function (copy from WorkScreen)
dynamic _parseId(dynamic id) {
  if (id == null) return null;
  if (id is int) return id;
  if (id is String) {
    final parsed = int.tryParse(id);
    return parsed ?? id; // Nếu parse thất bại, giữ nguyên string
  }
  return id;
}
