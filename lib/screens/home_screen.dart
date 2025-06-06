import 'package:flutter/material.dart';
import 'package:flutter_testt/screens/AddWorkHoursScreen.dart';
import 'package:flutter_testt/screens/report_screen.dart';
import '../db/database_helper.dart';
import '../services/auth_service.dart';
import 'work_approval_screen.dart';
import 'create_work_item_screen.dart';
import 'user_work_items_screen.dart';
import 'workscreen.dart';
import 'internalcommunicationscreen.dart';
import 'Personal_Information_Screen.dart';
import 'employee_list_screen.dart';
import 'welcome_screen.dart';
// Import tất cả các màn hình placeholder
import 'placeholder_screens.dart'
    hide
        WorkScreen,
        InternalCommunicationScreen,
        PersonalInformationScreen,
        EmployeeListScreen;

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
                // lịch biểu
                _buildDrawerItem(
                  Icons.schedule,
                  'Lịch Biểu',
                  dense: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkScheduleScreen(),
                      ),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProjectScreen()),
                    );
                  },
                ),

                _buildDrawerItem(
                  Icons.task_alt,
                  'Công Việc',
                  dense: true,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.pop(context);
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
          'Chào buổi trưa, ${widget.username}!',
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
      floatingActionButton:
          isAdmin
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkApprovalScreen(),
                    ),
                  );
                },
                label: const Text('Duyệt công việc'),
                icon: const Icon(Icons.approval),
                backgroundColor: Colors.blue,
              )
              : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CreateWorkItemScreen(
                            userId: widget.userId,
                            userName: widget.username,
                          ),
                    ),
                  );
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.blue,
              ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
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
        return const WorkScreen();
      case 1:
        return const InternalCommunicationScreen();
      case 2:
        return _buildMainHome();
      case 3:
        return const WorkScheduleScreen();
      case 4:
        return const NotificationScreen();
      default:
        return const Center(child: Text('Trang không tồn tại'));
    }
  }

  Widget _buildMainHome() {
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
                      builder: (_) => const LichSuChamCongScreen(),
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
            ],
          ),
        ),
        
        // Chỉ hiển thị nút "Vào Ca" cho người dùng thường (không phải admin)
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Vào Ca',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
                          builder: (_) => const PersonalInformationScreen(),
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
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Chữ ký điện tử'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment_turned_in_outlined),
                    title: const Text('Nhiệm vụ'),
                    onTap: () {
                      Navigator.pop(context); // Đóng bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TaskScreen()),
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
