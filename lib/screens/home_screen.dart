import 'package:flutter/material.dart';
import 'package:flutter_testt/screens/AddWorkHoursScreen.dart';
import 'package:flutter_testt/screens/report_screen.dart';
import '../db/database_helper.dart';
import 'work_approval_screen.dart';
import 'create_work_item_screen.dart';
import 'user_work_items_screen.dart';
import 'WorkScreen.dart';
import 'internalcommunicationscreen.dart' as internal_comm;
import 'Personal_Information_View_Screen.dart';
import 'employee_list_screen.dart';
import 'welcome_screen.dart';
import 'Work_Schedule_Screen.dart';
import 'change_password_screen.dart' as real_change_password;
import 'placeholder_screens.dart'
    hide
        WorkScreen,
        InternalCommunicationScreen,
        PersonalInformationScreen,
        EmployeeListScreen,
        WorkScheduleScreen,
        NotificationScreen,
        LichSuChamCongScreen;
import 'notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'assign_task_screen.dart';
import '../services/task_api.dart';
import 'task_list_screen.dart';
import 'components/admin_stat_cards.dart';
import 'components/admin_quick_report_card.dart';
import 'components/admin_recent_activity_card.dart';
import 'admin_statistics_screen.dart';
import 'digital_signature_screen.dart';
import 'LichSuChamCongScreen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final String username;

  const HomeScreen({
    super.key,
    this.isAdmin = false,
    this.userId = '1',
    this.username = 'User',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = true;
  int _selectedIndex = 2;

  bool get isAdmin => widget.isAdmin;

  List<dynamic> _users = [];
  bool _isLoadingUsers = false;
  List<Map<String, dynamic>> _tasks = [];
  
  // State để theo dõi trạng thái check-in/check-out
  bool _isCheckedIn = false;
  DateTime? _checkInTime;

  @override
  void initState() {
    super.initState();
    if (isAdmin) {
      _fetchUsers();
      _fetchTasks();
    }
    _checkTodayAttendanceStatus(); // Kiểm tra trạng thái chấm công hôm nay
  }

  // Function để kiểm tra trạng thái chấm công hôm nay
  Future<void> _checkTodayAttendanceStatus() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      // Danh sách endpoints để thử
      final endpointsToTry = [
        'http://10.0.2.2:8080/api/attendance',
        'http://10.0.2.2:8080/attendance',
        'http://localhost:8080/api/attendance',
        'http://localhost:8080/attendance',
        'http://127.0.0.1:8080/api/attendance',
      ];

      for (String endpoint in endpointsToTry) {
        try {
          String url = '$endpoint?userId=${widget.userId}&date=$today';
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            // Tìm record hôm nay
            if (data is List && data.isNotEmpty) {
              final todayRecord = data.firstWhere(
                (record) => record['workingDate'] == today,
                orElse: () => null,
              );
              
              if (todayRecord != null) {
                setState(() {
                  // Kiểm tra trạng thái: đã check-in nhưng chưa check-out
                  _isCheckedIn = todayRecord['checkIn'] != null && todayRecord['checkOut'] == null;
                  if (todayRecord['checkIn'] != null) {
                    _checkInTime = DateTime.parse(todayRecord['checkIn']);
                  }
                });
                print('DEBUG: Found today record - isCheckedIn: $_isCheckedIn, checkInTime: $_checkInTime');
              } else {
                setState(() {
                  _isCheckedIn = false;
                  _checkInTime = null;
                });
                print('DEBUG: No record found for today');
              }
            }
            break;
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      print('DEBUG: Error checking attendance status: $e');
    }
  }

  Future<void> _fetchUsers() async {
    setState(() { _isLoadingUsers = true; });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/users')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final allUsers = decoded is List ? decoded : [];
        setState(() {
          _users = allUsers.where((u) => (u['role'] ?? '').toString().toUpperCase() == 'USER').toList();
          _isLoadingUsers = false;
        });
      } else {
        setState(() { _isLoadingUsers = false; });
      }
    } catch (e) {
      setState(() { _isLoadingUsers = false; });
    }
  }

  Future<void> _fetchTasks() async {
    setState(() { });
    try {
      final tasks = await TaskApi.getAllTasks();
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      setState(() { });
    }
  }

  // Function để thực hiện check-in (vào ca)
  Future<void> _performCheckIn() async {
    try {
      // Lấy thông tin ngày hiện tại
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      final checkInTime = now.toIso8601String(); // Full ISO timestamp
      
      // Tạo data theo format yêu cầu
      final checkInData = {
        "user": {
          "id": int.tryParse(widget.userId) ?? 1
        },
        "workingDate": workingDate,
        "checkIn": checkInTime,
        "workingHours": 8,
        "overtimeHours": 0, // Mặc định 0, có thể tính sau
        "status": "pending"
      };

      print('DEBUG: Check-in data: ${jsonEncode(checkInData)}');

      // Danh sách endpoints để thử
      final endpointsToTry = [
        'http://10.0.2.2:8080/api/attendance',
        'http://10.0.2.2:8080/attendance',
        'http://localhost:8080/api/attendance',
        'http://localhost:8080/attendance',
        'http://127.0.0.1:8080/api/attendance',
      ];

      bool success = false;
      String lastError = '';

      // Thử từng endpoint cho đến khi thành công
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Trying check-in endpoint: $endpoint');
          
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(checkInData),
          ).timeout(const Duration(seconds: 10));

          print('DEBUG: Check-in response status: ${response.statusCode}');
          print('DEBUG: Check-in response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Thành công
            success = true;
            setState(() {
              _isCheckedIn = true;
              _checkInTime = now;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Vào ca thành công lúc ${_formatTime(now)}!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            break; // Thoát khỏi loop khi thành công
          } else {
            lastError = 'Status ${response.statusCode}: ${response.body}';
            continue; // Thử endpoint tiếp theo
          }
        } catch (e) {
          print('DEBUG: Check-in endpoint $endpoint failed: $e');
          lastError = e.toString();
          continue; // Thử endpoint tiếp theo
        }
      }

      // Nếu tất cả endpoints đều thất bại
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi vào ca: $lastError\nVui lòng kiểm tra server và thử lại.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Check-in general exception: $e');
      // Lỗi kết nối tổng quát
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi kết nối: $e\nVui lòng kiểm tra server và thử lại.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Function để thực hiện check-out (kết thúc ca)
  Future<void> _performCheckOut() async {
    try {
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      final checkOutTime = now.toIso8601String(); // Full ISO timestamp

      // Tính số giờ làm việc nếu có thông tin check-in
      double workingHours = 8.0; // Mặc định 8 giờ
      if (_checkInTime != null) {
        final duration = now.difference(_checkInTime!);
        workingHours = duration.inMinutes / 60.0;
        workingHours = double.parse(workingHours.toStringAsFixed(2));
      }

      print('DEBUG: Check-out started for date: $workingDate, time: $checkOutTime');
      print('DEBUG: Working hours calculated: $workingHours');

      // Danh sách endpoints để thử (ưu tiên localhost:8080 theo yêu cầu)
      final endpointsToTry = [
        'http://localhost:8080/api/attendance',
        'http://10.0.2.2:8080/api/attendance',
        'http://10.0.2.2:8080/attendance',
        'http://localhost:8080/attendance',
        'http://127.0.0.1:8080/api/attendance',
      ];

      bool success = false;
      String lastError = '';

      // Thử từng endpoint để tìm và cập nhật record hôm nay
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Trying check-out with endpoint: $endpoint');
          
          // Bước 1: Tìm record hôm nay
          String getUrl = '$endpoint?userId=${widget.userId}&date=$workingDate';
          final getResponse = await http.get(
            Uri.parse(getUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (getResponse.statusCode == 200) {
            final data = jsonDecode(getResponse.body);
            
            if (data is List && data.isNotEmpty) {
              // Tìm record hôm nay
              final todayRecord = data.firstWhere(
                (record) => record['workingDate'] == workingDate,
                orElse: () => null,
              );
              
              if (todayRecord != null && todayRecord['id'] != null) {
                // Bước 2: Cập nhật record với checkOut (chỉ gửi checkOut theo yêu cầu)
                final updateData = {
                  "checkOut": checkOutTime
                };

                print('DEBUG: Update data: ${jsonEncode(updateData)}');

                // Thử PUT để cập nhật
                final putResponse = await http.put(
                  Uri.parse('$endpoint/${todayRecord['id']}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode(updateData),
                ).timeout(const Duration(seconds: 10));

                print('DEBUG: Check-out PUT response status: ${putResponse.statusCode}');
                print('DEBUG: Check-out PUT response body: ${putResponse.body}');

                if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
                  success = true;
                  setState(() {
                    _isCheckedIn = false;
                    _checkInTime = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Kết thúc ca thành công lúc ${_formatTime(now)}!\nTổng giờ làm: ${workingHours.toStringAsFixed(2)} giờ'),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  break;
                } else {
                  lastError = 'PUT Status ${putResponse.statusCode}: ${putResponse.body}';
                  continue;
                }
              } else {
                lastError = 'Không tìm thấy record check-in hôm nay';
                continue;
              }
            } else {
              lastError = 'Không có dữ liệu chấm công';
              continue;
            }
          } else {
            lastError = 'GET Status ${getResponse.statusCode}: ${getResponse.body}';
            continue;
          }
        } catch (e) {
          print('DEBUG: Check-out endpoint $endpoint failed: $e');
          lastError = e.toString();
          continue;
        }
      }

      // Nếu tất cả endpoints đều thất bại
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi kết thúc ca: $lastError\nVui lòng kiểm tra server và thử lại.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Check-out general exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi kết nối: $e\nVui lòng kiểm tra server và thử lại.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Helper function để format thời gian hiển thị
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper function để tính toán thời gian làm việc
  String _calculateWorkingHours() {
    if (_checkInTime == null) return '0.00';
    
    final now = DateTime.now();
    final duration = now.difference(_checkInTime!);
    final hours = duration.inMinutes / 60.0;
    return hours.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(widget.username),
              accountEmail: Text(isAdmin ? 'Quản trị viên' : 'Người dùng'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerSectionTitle('WORKSPACE'),
            ExpansionTile(
              leading: const Icon(Icons.extension),
              title: const Text('Tiện Ích'),
              children: [
                _buildDrawerItem(
                  Icons.chat_bubble_outline,
                  'Chat',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                ),
                // Lịch làm
                _buildDrawerItem(
                  Icons.calendar_month,
                  'Lịch làm',
                  dense: true,
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                // Lịch làm
                _buildDrawerItem(
                  Icons.insert_drive_file,
                  'Tài Liệu',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.insert_drive_file,
                  'Hộp Thư Góp Ý',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuggestionBoxScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('Công Việc'),
              children: [
                _buildDrawerItem(
                  Icons.assignment,
                  'Dự Án',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 0); // Chuyển đến tab Công việc (WorkScreen)
                  },
                ),

                _buildDrawerItem(
                  Icons.access_time,
                  'Chấm Công',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LichSuChamCongScreen(userId: widget.userId),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildDrawerSectionTitle('HRM'),
            _buildDrawerItem(
              Icons.groups,
              'Nhân Sự',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeScreen()),
                );
              },
            ),

            _buildDrawerItem(
              Icons.how_to_reg,
              'Tuyển Dụng',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecruitmentScreen()),
                );
              },
            ),

            _buildDrawerSectionTitle('SYSTEM'),
            _buildDrawerItem(
              Icons.bar_chart,
              'Báo Cáo',
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()),
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Chào buổi trưa, \\${widget.username}!',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showUserMenu(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 2
          ? (isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignTaskScreen(allUsers: _users),
                      ),
                    );
                  },
                  label: const Text('Giao nhiệm vụ'),
                  icon: const Icon(Icons.assignment_turned_in),
                  backgroundColor: Colors.blue,
                )
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateWorkItemScreen(
                          userId: widget.userId,
                          userName: widget.username,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                ))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2 && isAdmin) {
            _fetchUsers();
            _fetchTasks(); // Đảm bảo luôn cập nhật số nhiệm vụ khi vào Trang chủ
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Nội bộ'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch làm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return WorkScreen(isAdmin: isAdmin);
      case 1:
        return internal_comm.InternalCommunicationScreen(isAdmin: isAdmin);
      case 2:
        return _buildMainHome();
      case 3:
        // Truyền userId (String) thành int cho employeeId/createdBy
        return WorkScheduleScreen(
          employeeId: int.tryParse(widget.userId) ?? 1,
          createdBy: int.tryParse(widget.userId) ?? 1,
        );
      case 4:
        return const NotificationScreen();
      default:
        return const Center(child: Text('Trang không tồn tại'));
    }
  }

  Widget _buildMainHome() {
    if (isAdmin) {
      // Trang chủ cho admin: Thống kê nhanh
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thống kê nhanh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            AdminStatCards(
              isLoadingUsers: _isLoadingUsers,
              onUserTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeListScreen(),
                  ),
                );
              },
              onTaskTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TaskListScreen(tasks: _tasks)));
              },
              onApprovalTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkApprovalScreen()));
              },
            ),
            const SizedBox(height: 24),
            AdminQuickReportCard(
              totalUsers: _users.length,
              totalTasks: _tasks.length,
              completedTasks: _tasks.where((t) => t['status'] == 'completed').length,
              overdueTasks: _tasks.where((t) => t['status'] == 'overdue' || (t['dueDate'] != null && DateTime.tryParse(t['dueDate']) != null && DateTime.tryParse(t['dueDate'])!.isBefore(DateTime.now()) && t['status'] != 'completed')).length,
              onLeaveUsers: _users.where((u) => (u['work_status'] ?? '').toLowerCase().contains('nghỉ')).length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminStatisticsScreen(
                      totalUsers: _users.length,
                      onLeaveUsers: _users.where((u) => (u['work_status'] ?? '').toLowerCase().contains('nghỉ')).length,
                      totalTasks: _tasks.length,
                      completedTasks: _tasks.where((t) => t['status'] == 'completed').length,
                      overdueTasks: _tasks.where((t) => t['status'] == 'overdue' || (t['dueDate'] != null && DateTime.tryParse(t['dueDate']) != null && DateTime.tryParse(t['dueDate'])!.isBefore(DateTime.now()) && t['status'] != 'completed')).length,
                      users: _users.cast<Map<String, dynamic>>(),
                      tasks: _tasks,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const AdminRecentActivityCard(),
          ],
        ),
      );
    }
    // Giao diện cho người dùng thường
    return Column(
      children: [
        // Admin approval section
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Phê duyệt công việc',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        FutureBuilder<int>(
                          future: DatabaseHelper().countPendingWorkItems(),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: count > 0 ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$count việc cần duyệt',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn có thẩm quyền phê duyệt các yêu cầu từ nhân viên.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Kiểm tra quyền admin trước khi chuyển đến màn hình phê duyệt
                          if (isAdmin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkApprovalScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Bạn không có quyền truy cập tính năng này',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),          ),

        // Hiển thị "Yêu cầu của tôi" chỉ cho người dùng thường, không phải admin
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Yêu cầu của tôi ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<int>(
                      future: DatabaseHelper().countPendingWorkItems(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => UserWorkItemsScreen(
                              userId: widget.userId,
                              userName: widget.username,
                            ),
                      ),
                    );
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(12),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              //  chức năng nghỉ phép
              _buildIconTile(
                Icons.edit_note,
                'Nghỉ phép',
                Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaveRequestScreen(),
                    ),
                  );
                },
              ),
              // Nhiệm vụ
              _buildIconTile(
                Icons.assignment_turned_in,
                'Nhiệm vụ',
                Colors.green,
                onTap: () async {
                  final tasks = await TaskApi.getTasksByUsername(widget.username);
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskListScreen(tasks: tasks),
                    ),
                  );
                },
              ),
              // chức năng bổ sung công
              _buildIconTile(
                Icons.add_circle,
                'Bổ sung công',
                Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddWorkHoursScreen(),
                    ),
                  );
                },
              ),
              // hòm thư góp ý
              _buildIconTile(
                Icons.forum,
                'Hộp thư góp ý',
                Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SuggestionBoxScreen(),
                    ),
                  );
                },
              ),

              _buildIconTile(
                Icons.attach_money,
                'Phiếu Tạm Ứng',
                Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdvanceRequestScreen(),
                    ),
                  );
                },
              ),
              //lijlich su cham cong
              _buildIconTile(
                Icons.access_time,
                'Lịch Sử Chấm Công',
                Colors.lightBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LichSuChamCongScreen(userId: widget.userId),
                    ),
                  );
                },
              ),

              // công tác
              _buildIconTile(
                Icons.flight_takeoff,
                'Công tác',
                Colors.deepOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CongTacScreen()),
                  );
                },
              ),
              // châm công ho
              _buildIconTile(
                Icons.location_on,
                'Công tác',
                Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChamCongHoScreen()),
                  );
                },
              ),
              // chức năng chữ ký số
              // _buildIconTile(
              //   Icons.edit,
              //   'Chữ ký số',
              //   Colors.purple,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => DigitalSignatureScreen(username: widget.username),
              //       ),
              //     );
              //   },
              // ),
              // bảng công nhân viên
              // _buildIconTile(
              //   Icons.calendar_today_outlined,
              //   'Bảng công nhân viên',
              //   Colors.blue,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => const AttendanceCalendarScreen(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
        
        // Chỉ hiển thị nút chấm công cho người dùng thường (không phải admin)
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () async {
                if (_isCheckedIn) {
                  // Hiển thị dialog xác nhận kết thúc ca
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xác nhận kết thúc ca'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thời gian kết thúc: ${_formatTime(DateTime.now())}'),
                          const SizedBox(height: 8),
                          Text('Ngày: ${DateTime.now().toIso8601String().substring(0, 10)}'),
                          const SizedBox(height: 8),
                          if (_checkInTime != null) ...[
                            Text('Thời gian vào ca: ${_formatTime(_checkInTime!)}'),
                            const SizedBox(height: 8),
                            Text('Tổng thời gian làm việc: ${_calculateWorkingHours()} giờ'),
                            const SizedBox(height: 8),
                          ],
                          const Text('Bạn có chắc muốn kết thúc ca không?'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Kết thúc Ca', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  // Nếu user xác nhận, thực hiện check-out
                  if (confirm == true) {
                    await _performCheckOut();
                  }
                } else {
                  // Hiển thị dialog xác nhận vào ca
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Xác nhận vào ca'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thời gian: ${_formatTime(DateTime.now())}'),
                          const SizedBox(height: 8),
                          Text('Ngày: ${DateTime.now().toIso8601String().substring(0, 10)}'),
                          const SizedBox(height: 8),
                          const Text('Bạn có chắc muốn vào ca không?'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Vào Ca', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  // Nếu user xác nhận, thực hiện check-in
                  if (confirm == true) {
                    await _performCheckIn();
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isCheckedIn ? Icons.logout : Icons.access_time,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCheckedIn ? 'Kết thúc Ca' : 'Vào Ca',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconTile(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder:
          (_) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Thông tin cá nhân'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalInformationViewScreen(username: widget.username),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Đổi mật khẩu'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => real_change_password.ChangePasswordScreen(username: widget.username),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Chữ ký điện tử'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DigitalSignatureScreen(username: widget.username),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Bảng công nhân viên'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceCalendarScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Bảng công tăng ca'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.money_outlined),
                    title: const Text('Bảng lương nhân viên'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SalaryDetailScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('Khen thưởng & Kỷ luật'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Danh sách nhân viên'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeListScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Đăng xuất'),
                    onTap: () {
                      Navigator.pop(context); // Đóng Drawer
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

Widget _buildDrawerItem(
  IconData icon,
  String title, {
  VoidCallback? onTap,
  bool dense = false,
}) {
  return ListTile(
    dense: dense,
    leading: Icon(icon),
    title: Text(title),
    onTap: onTap,
  );
}

Widget _buildDrawerSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
    ),
  );
}