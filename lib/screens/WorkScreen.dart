import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class WorkScreen extends StatefulWidget {
  final bool isAdmin;
  const WorkScreen({super.key, this.isAdmin = false});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = false;
  String? _workingBaseUrl; // Lưu URL working để dùng cho tất cả requests
  Map<String, dynamic> _projectIdMap = {}; // Lưu mapping projectName + id -> parsed id
  
  // Cấu hình base URL - tự động detect platform
  static String get baseUrl {
    // Thử nhiều URL khác nhau cho các trường hợp khác nhau
    if (kIsWeb) {
      return 'http://localhost:8080'; // Web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // Android Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8080'; // iOS Simulator
    } else {
      return 'http://localhost:8080'; // Desktop
    }
  }
  
  // Backup URLs để thử khi main URL fail
  static const List<String> backupUrls = [
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://10.0.2.2:8080',
    'http://192.168.1.100:8080', // Thay bằng IP thực của máy
  ];

  // Helper function để test connection với multiple URLs
  Future<String?> _findWorkingBaseUrl() async {
    final urlsToTry = [baseUrl, ...backupUrls];
    
    for (String url in urlsToTry) {
      try {
        print('DEBUG: Testing connection to $url');
        final testUrl = Uri.parse('$url/api/projects');
        final response = await http.get(testUrl).timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw 'Timeout',
        );
        
        if (response.statusCode == 200 || response.statusCode == 404) {
          print('DEBUG: ✅ Connection successful to $url');
          return url;
        }
      } catch (e) {
        print('DEBUG: ❌ Failed to connect to $url - $e');
        continue;
      }
    }
    
    print('DEBUG: ❌ All URLs failed');
    return null;
  }

  // Helper method để parse ID từ string hoặc số với validation
  dynamic _parseId(dynamic id) {
    if (id == null || id.toString().trim().isEmpty) {
      return null;
    }
    
    // Nếu đã là số, return luôn
    if (id is int) {
      return id;
    }
    
    // Nếu là string, thử parse
    if (id is String) {
      final trimmed = id.trim();
      
      // Thử parse thành int
      final intParsed = int.tryParse(trimmed);
      if (intParsed != null) {
        return intParsed;
      }
      
      // Thử parse thành double rồi convert về int
      final doubleParsed = double.tryParse(trimmed);
      if (doubleParsed != null && doubleParsed == doubleParsed.toInt()) {
        return doubleParsed.toInt();
      }
      
      // Nếu không parse được thành số, kiểm tra xem có phải UUID/string ID hợp lệ không
      if (trimmed.length > 0 && !trimmed.contains(' ')) {
        return trimmed; // Giữ nguyên string ID
      }
    }
    
    // Nếu là type khác (double, bool, etc)
    if (id is double && id == id.toInt()) {
      return id.toInt();
    }
    
    // Last resort: convert toString và thử parse
    final stringValue = id.toString().trim();
    if (stringValue.isNotEmpty && stringValue != 'null') {
      final lastTryInt = int.tryParse(stringValue);
      if (lastTryInt != null) {
        return lastTryInt;
      }
      return stringValue; // Return as string ID
    }
    
    return null;
  }

  // Helper method để tạo unique key cho project
  String _getProjectKey(Map<String, dynamic> project) {
    final name = project['projectName'] ?? project['name'] ?? '';
    final id = project['id']?.toString() ?? '';
    return '$name-$id';
  }

  // Helper method để lấy ID đã lưu từ mapping với fallback
  dynamic _getProjectId(Map<String, dynamic> project) {
    final key = _getProjectKey(project);
    final mappedId = _projectIdMap[key];
    
    if (mappedId != null) {
      print('🔍 Found mapped ID for "$key": $mappedId (type: ${mappedId.runtimeType})');
      return mappedId;
    }
    
    // Fallback 1: parse trực tiếp ID field
    final directId = _parseId(project['id']);
    if (directId != null) {
      print('⚠️ No mapping found for "$key", using direct ID: $directId (type: ${directId.runtimeType})');
      return directId;
    }
    
    // Fallback 2: thử các field ID khác
    final alternativeFields = ['projectId', '_id', 'uuid', 'key'];
    for (String field in alternativeFields) {
      final altId = _parseId(project[field]);
      if (altId != null) {
        print('🔧 Using alternative field "$field": $altId (type: ${altId.runtimeType})');
        return altId;
      }
    }
    
    // Fallback 3: thử tìm ID bằng tên trong mapping
    final projectName = project['projectName'] ?? project['name'] ?? '';
    if (projectName.isNotEmpty) {
      for (var entry in _projectIdMap.entries) {
        if (entry.key.startsWith(projectName)) {
          print('🔍 Found ID by name match "$projectName": ${entry.value}');
          return entry.value;
        }
      }
    }
    
    print('❌ No valid ID found for project: $project');
    return null;
  }

  // Helper method để debug thông tin project
  void _debugProjectInfo(Map<String, dynamic> project, String action) {
    final key = _getProjectKey(project);
    final directId = project['id'];
    final mappedId = _projectIdMap[key];
    print('🔍 [$action] Project debug:');
    print('   - Name: ${project['projectName'] ?? project['name']}');
    print('   - Key: $key');
    print('   - Direct ID: $directId (type: ${directId.runtimeType})');
    print('   - Mapped ID: $mappedId (type: ${mappedId?.runtimeType})');
  }

  // Helper method để debug toàn bộ trạng thái mapping
  void _debugMappingState() {
    print('\n🗺️ === MAPPING STATE DEBUG ===');
    print('Working URL: $_workingBaseUrl');
    print('Total projects: ${projects.length}');
    print('Total mappings: ${_projectIdMap.length}');
    
    print('\n📋 Projects list:');
    for (int i = 0; i < projects.length; i++) {
      final p = projects[i];
      print('  [$i] ${p['projectName']} - ID: ${p['id']} (${p['id'].runtimeType})');
    }
    
    print('\n🗂️ ID Mappings:');
    if (_projectIdMap.isEmpty) {
      print('  (No mappings found)');
    } else {
      _projectIdMap.forEach((key, id) {
        print('  "$key" -> $id (${id.runtimeType})');
      });
    }
    
    print('\n🔍 Cross-check (projects vs mappings):');
    for (int i = 0; i < projects.length; i++) {
      final p = projects[i];
      final key = _getProjectKey(p);
      final mappedId = _projectIdMap[key];
      final directId = p['id'];
      
      print('  Project "${p['projectName']}":');
      print('    Key: "$key"');
      print('    Direct ID: $directId');
      print('    Mapped ID: $mappedId');
      print('    Match: ${mappedId == directId ? '✅' : '❌'}');
    }
    print('=== END MAPPING DEBUG ===\n');
  }

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    setState(() => isLoading = true);
    
    // Tìm URL working trước
    final workingUrl = await _findWorkingBaseUrl();
    if (workingUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không thể kết nối tới server. Vui lòng kiểm tra:\n'
                '• Server đã chạy chưa?\n'
                '• URL có đúng không?\n'
                '• Firewall/Antivirus có block không?'),
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => fetchProjects(),
            ),
          ),
        );
      }
      setState(() => isLoading = false);
      return;
    }
    
    // Lưu working URL để dùng cho các function khác
    _workingBaseUrl = workingUrl;
    print('DEBUG: Working URL saved: $_workingBaseUrl');
    
    final url = Uri.parse('$workingUrl/api/projects');
    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw 'Request timeout - Server có thể quá chậm',
      );
      
      print('DEBUG: GET Response status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: GET Response data: $data'); // Debug log để xem cấu trúc data
        
        if (data is List) {
          projects = List<Map<String, dynamic>>.from(data);
          print('DEBUG: Projects loaded: ${projects.length} items');
          
          // Clear và rebuild ID mapping từ GET response
          _projectIdMap.clear();
          
          for (int i = 0; i < projects.length; i++) {
            final project = projects[i];
            print('🔍 Project $i structure: ${project.keys}');
            print('🔍 Project $i id: ${project['id']} (type: ${project['id'].runtimeType})');
            print('🔍 Project $i name: ${project['name'] ?? project['projectName']}');
            
            // Build unique key và lưu parsed ID vào mapping
            final key = _getProjectKey(project);
            final parsedId = _parseId(project['id']);
            _projectIdMap[key] = parsedId;
            
            print('✅ Saved to mapping: "$key" -> $parsedId (type: ${parsedId.runtimeType})');
          }
          
          print('🗂️ ID Mapping summary:');
          _projectIdMap.forEach((key, id) {
            print('   "$key" -> $id (${id.runtimeType})');
          });
          
          // Debug toàn bộ trạng thái
          _debugMappingState();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tải dữ liệu: ${response.statusCode}\n${response.body}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: GET Exception: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $e\n\nĐề xuất:\n• Kiểm tra server đã chạy\n• Thử URL khác trong code'),
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => fetchProjects(),
            ),
          ),
        );
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> createOrEditProject({Map<String, dynamic>? project}) async {
    final isEdit = project != null;
    final TextEditingController nameCtrl = TextEditingController(text: project?['projectName'] ?? '');
    final TextEditingController descCtrl = TextEditingController(text: project?['description'] ?? '');
    final TextEditingController startCtrl = TextEditingController(text: project?['startDate'] ?? '');
    final TextEditingController endCtrl = TextEditingController(text: project?['endDate'] ?? '');
    final TextEditingController managerCtrl = TextEditingController(text: project?['projectManager'] ?? '');
    String status = project?['status'] ?? 'planned';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            isEdit ? 'Sửa dự án' : 'Tạo dự án mới',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên dự án'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl,
                        decoration: const InputDecoration(labelText: 'Ngày bắt đầu (yyyy-MM-dd)'),
                        style: const TextStyle(fontSize: 16),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startCtrl.text.isNotEmpty
                                ? DateTime.tryParse(startCtrl.text) ?? DateTime.now()
                                : DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            startCtrl.text = picked.toIso8601String().substring(0, 10);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: endCtrl,
                        decoration: const InputDecoration(labelText: 'Ngày kết thúc (yyyy-MM-dd)'),
                        style: const TextStyle(fontSize: 16),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endCtrl.text.isNotEmpty
                                ? DateTime.tryParse(endCtrl.text) ?? DateTime.now()
                                : DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            endCtrl.text = picked.toIso8601String().substring(0, 10);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: managerCtrl,
                  decoration: const InputDecoration(labelText: 'Quản lý dự án'),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Trạng thái:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'planned', child: Text('Planned')),
                          DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (v) => setState(() => status = v ?? 'planned'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
              textStyle: const TextStyle(fontSize: 18),
            ),
            onPressed: () async {
              final data = {
                'projectName': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'startDate': startCtrl.text.trim(),
                'endDate': endCtrl.text.trim(),
                'projectManager': managerCtrl.text.trim(),
                'status': status,
              };
              // Validate dữ liệu trước khi gửi
              if (data.values.any((v) => v.toString().isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin dự án!')),
                );
                return;
              }
              
              // Validate ngày
              final startDate = DateTime.tryParse(startCtrl.text);
              final endDate = DateTime.tryParse(endCtrl.text);
              if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ngày kết thúc không được trước ngày bắt đầu!')),
                );
                return;
              }
              // Kiểm tra working URL có sẵn không
              if (_workingBaseUrl == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lỗi: Chưa có kết nối tới server!')),
                );
                return;
              }
              
              // Debug project info
              if (isEdit) {
                _debugProjectInfo(project, 'EDIT PROJECT');
                
                // Lấy ID từ mapping với validation chi tiết
                final projectId = _validateAndGetProjectId(project);
                print('DEBUG: Final validated ID: $projectId');
                
                if (projectId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lỗi: Không thể xác định ID dự án để cập nhật!')),
                  );
                  return;
                }
                
                // Test và thực hiện update với multiple methods
                final success = await _performUpdate(projectId, data);
                if (success) {
                  Navigator.pop(context);
                  await fetchProjects();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật dự án thành công!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lỗi cập nhật dự án: Không tìm thấy method phù hợp'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
                return;
              }
              
              // Tạo mới project (POST)
              final url = Uri.parse('$_workingBaseUrl/api/projects');
              print('DEBUG: URL: $url');
              print('DEBUG: Method: POST');
              print('DEBUG: Body: ${jsonEncode(data)}');
              
              try {
                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode(data),
                );
                
                print('DEBUG: Response status: ${response.statusCode}');
                print('DEBUG: Response body: ${response.body}');
                
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  await fetchProjects();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Cập nhật dự án thành công!' : 'Tạo dự án thành công!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi ${isEdit ? 'cập nhật' : 'tạo'} dự án: ${response.statusCode}\n${response.body}'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              } catch (e) {
                print('DEBUG: Exception: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi kết nối: $e')),
                );
              }
            },
            child: Text(isEdit ? 'Lưu' : 'Tạo'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteProject(dynamic projectOrId) async {
    print('\n🗑️ === DELETE PROJECT DEBUG ===');
    print('Input: $projectOrId (type: ${projectOrId.runtimeType})');
    
    // Kiểm tra working URL có sẵn không
    if (_workingBaseUrl == null) {
      print('❌ No working base URL');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Chưa có kết nối tới server!')),
      );
      return;
    }
    
    // Debug chi tiết input data
    if (projectOrId is Map<String, dynamic>) {
      print('📊 Project object details:');
      print('   - Keys: ${projectOrId.keys.toList()}');
      print('   - ID field: ${projectOrId['id']} (type: ${projectOrId['id'].runtimeType})');
      print('   - Name: ${projectOrId['projectName'] ?? projectOrId['name']}');
      
      // Debug mapping state
      final key = _getProjectKey(projectOrId);
      print('   - Generated key: "$key"');
      print('   - Mapped ID: ${_projectIdMap[key]} (type: ${_projectIdMap[key]?.runtimeType})');
      print('   - Current mapping state:');
      _projectIdMap.forEach((k, v) {
        print('     "$k" -> $v (${v.runtimeType})');
      });
    }
    
    // Lấy ID từ project data hoặc direct ID
    dynamic projectId;
    if (projectOrId is Map<String, dynamic>) {
      // Sử dụng validateAndGetProjectId để có debug chi tiết
      projectId = _validateAndGetProjectId(projectOrId);
      print('✅ Final extracted ID: $projectId (type: ${projectId.runtimeType})');
    } else {
      // Nếu truyền vào là ID trực tiếp
      projectId = _parseId(projectOrId);
      print('✅ Direct parsed ID: $projectId (type: ${projectId.runtimeType})');
    }

    if (projectId == null) {
      print('❌ Project ID is null - cannot delete');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa dự án: ID không hợp lệ!\n\nDebug info:\n• Input: $projectOrId\n• Extracted ID: $projectId'),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    
    print('🎯 Using project ID for deletion: $projectId');
    print('=== END DELETE DEBUG ===\n');

    final url = Uri.parse('$_workingBaseUrl/api/projects/$projectId');
    print('DEBUG: DELETE URL: $url'); // Debug log
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa dự án này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        
        print('DEBUG: DELETE Response status: ${response.statusCode}'); // Debug log
        print('DEBUG: DELETE Response body: ${response.body}'); // Debug log
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          await fetchProjects();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa dự án thành công!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa dự án: ${response.statusCode}\n${response.body}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print('DEBUG: DELETE Exception: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: $e')),
        );
      }
    }
  }

  // Helper method để test PUT request với projectId
  // Helper method để validate projectId từ nhiều nguồn
  dynamic _validateAndGetProjectId(Map<String, dynamic> project) {
    print('\n🔍 === PROJECT ID VALIDATION ===');
    print('Project data: $project');
    
    // 1. ID trực tiếp từ project
    final directId = project['id'];
    print('1. Direct ID: $directId (type: ${directId.runtimeType})');
    
    // 2. ID từ mapping
    final key = _getProjectKey(project);
    final mappedId = _projectIdMap[key];
    print('2. Mapping key: "$key"');
    print('3. Mapped ID: $mappedId (type: ${mappedId?.runtimeType})');
    
    // 3. Parsed ID
    final parsedId = _parseId(directId);
    print('4. Parsed ID: $parsedId (type: ${parsedId.runtimeType})');
    
    // 4. Tìm ID trong các fields khác
    final alternativeIds = [
      project['projectId'],
      project['_id'],
      project['uuid'],
    ].where((id) => id != null).toList();
    print('5. Alternative IDs: $alternativeIds');
    
    // 5. Quyết định ID nào sử dụng
    dynamic finalId;
    if (mappedId != null) {
      finalId = mappedId;
      print('✅ Using mapped ID: $finalId');
    } else if (parsedId != null) {
      finalId = parsedId;
      print('✅ Using parsed ID: $finalId');
    } else if (alternativeIds.isNotEmpty) {
      finalId = alternativeIds.first;
      print('✅ Using alternative ID: $finalId');
    } else {
      print('❌ No valid ID found!');
      return null;
    }
    
    print('=== END VALIDATION ===\n');
    return finalId;
  }

  // Helper method để thực hiện update với multiple methods
  Future<bool> _performUpdate(dynamic projectId, Map<String, dynamic> data) async {
    if (_workingBaseUrl == null) {
      print('❌ No working base URL available');
      return false;
    }

    print('🔧 Attempting to update project ID: $projectId');
    print('📦 Data: ${jsonEncode(data)}');

    // Danh sách methods để thử (theo thứ tự ưu tiên)
    final methodsToTry = [
      {'method': 'PATCH', 'description': 'PATCH (recommended for partial updates)'},
      {'method': 'PUT', 'description': 'PUT (full resource replacement)'},
      {'method': 'POST', 'description': 'POST (alternative update)'},
    ];

    // Danh sách endpoints để thử
    final endpointsToTry = [
      '$_workingBaseUrl/api/projects/$projectId',
      '$_workingBaseUrl/api/project/$projectId', // Singular
      '$_workingBaseUrl/projects/$projectId',    // No /api
      '$_workingBaseUrl/project/$projectId',     // No /api, singular
      '$_workingBaseUrl/api/projects/$projectId/update', // Explicit update endpoint
    ];

    for (var methodInfo in methodsToTry) {
      final method = methodInfo['method']!;
      print('\n🧪 Trying $method - ${methodInfo['description']}');

      for (String endpoint in endpointsToTry) {
        try {
          print('   🌐 Testing: $method $endpoint');
          
          http.Response? response;
          final uri = Uri.parse(endpoint);
          
          switch (method) {
            case 'PATCH':
              response = await http.patch(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(data),
              ).timeout(const Duration(seconds: 10));
              break;
              
            case 'PUT':
              response = await http.put(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(data),
              ).timeout(const Duration(seconds: 10));
              break;
              
            case 'POST':
              response = await http.post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(data),
              ).timeout(const Duration(seconds: 10));
              break;
          }

          print('      Status: ${response?.statusCode}');
          
          if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
            print('      ✅ SUCCESS! Update completed with $method');
            print('      Response: ${response.body}');
            return true;
          } else if (response?.statusCode == 405) {
            print('      ❌ Method Not Allowed (405)');
            break; // Thử method khác
          } else if (response?.statusCode == 404) {
            print('      ❌ Not Found (404) - trying next endpoint');
            continue; // Thử endpoint khác
          } else {
            print('      ⚠️  Unexpected status: ${response?.statusCode}');
            print('      Response: ${response?.body}');
          }

        } catch (e) {
          print('      ❌ Exception: $e');
          continue;
        }
      }
    }

    print('❌ All update methods failed');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Dự án'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.separated(
                itemCount: projects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final p = projects[index];
                  return Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.folder_special_rounded, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p['projectName'] ?? '',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mô tả: ${p['description'] ?? ''}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Thời gian: ${p['startDate']} - ${p['endDate']}', style: const TextStyle(fontSize: 15)),
                                const SizedBox(height: 8),
                                Text('Quản lý: ${p['projectManager']}', style: const TextStyle(fontSize: 15)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Trạng thái:', style: TextStyle(fontSize: 15)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: p['status'],
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(value: 'planned', child: Text('Planned')),
                                          DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                        ],
                                        onChanged: widget.isAdmin
                                            ? (v) async {
                                                if (v != null && v != p['status']) {
                                                  // Kiểm tra working URL có sẵn không
                                                  if (_workingBaseUrl == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Lỗi: Chưa có kết nối tới server!')),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // Validate và lấy project ID 
                                                  final projectId = _validateAndGetProjectId(p);
                                                  if (projectId == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Lỗi: Không thể xác định ID dự án!')),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  print('DEBUG: Update status - Project ID: $projectId');
                                                  print('DEBUG: Update status - New status: $v');
                                                  
                                                  // Chuẩn bị data với đầy đủ thông tin
                                                  final updated = {
                                                    'projectName': p['projectName'] ?? '',
                                                    'description': p['description'] ?? '',
                                                    'startDate': p['startDate'] ?? '',
                                                    'endDate': p['endDate'] ?? '',
                                                    'projectManager': p['projectManager'] ?? '',
                                                    'status': v,
                                                  };
                                                  
                                                  // Validate trước khi gửi
                                                  if (updated.values.any((val) => val.toString().isEmpty)) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Vui lòng đảm bảo đầy đủ thông tin dự án trước khi đổi trạng thái!')),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // Sử dụng _performUpdate để thử multiple methods
                                                  final success = await _performUpdate(projectId, updated);
                                                  if (success) {
                                                    Navigator.pop(context);
                                                    await fetchProjects();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Cập nhật trạng thái thành công!')),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Lỗi cập nhật trạng thái: Không tìm thấy method phù hợp')),
                                                    );
                                                  }
                                                }
                                              }
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar hình tròn với icon hoặc ảnh dự án
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(Icons.folder_special_rounded, size: 36, color: Colors.blueAccent),
                            ),
                            const SizedBox(width: 18),
                            // Thông tin dự án
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p['projectName'] ?? '',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.isAdmin)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.orange, size: 26),
                                              onPressed: () {
                                                _debugProjectInfo(p, 'BEFORE EDIT');
                                                createOrEditProject(project: p);
                                              },
                                              tooltip: 'Sửa dự án',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red, size: 26),
                                              onPressed: () {
                                                print('\n🚀 DELETE BUTTON PRESSED');
                                                _debugProjectInfo(p, 'BEFORE DELETE');
                                                _debugMappingState(); // Debug mapping trước khi delete
                                                deleteProject(p); // Truyền toàn bộ project object
                                              },
                                              tooltip: 'Xóa dự án',
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p['description'] ?? '',
                                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // DEBUG: Hiển thị ID để kiểm tra
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID: ${p['id']} (${p['id'].runtimeType})',
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        Text(
                                          'Mapped: ${_getProjectId(p)}',
                                          style: const TextStyle(fontSize: 10, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 18,
                                    runSpacing: 6,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${p['startDate']} - ${p['endDate']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.person, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            p['projectManager'] ?? '',
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.flag, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            p['status'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: p['status'] == 'completed'
                                                  ? Colors.green
                                                  : p['status'] == 'in_progress'
                                                      ? Colors.orange
                                                      : Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => createOrEditProject(),
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.add),
              label: const Text('Thêm dự án', style: TextStyle(fontSize: 18)),
              tooltip: 'Tạo dự án mới',
            )
          : null,
    );
  }
}
