import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'employee_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false; // Trạng thái đăng nhập

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child:
                isLoggedIn
                    ? GestureDetector(
                      onTap: () => _showUserMenu(context),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.account_circle, color: Colors.indigo),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.login, color: Colors.indigo),
                      // Khi ấn login
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            isLoggedIn = true;
                          });
                        }
                      },
                    ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  TagChip(label: 'Mặt hàng 1'),
                  SizedBox(width: 10),
                  TagChip(label: 'Mặt hàng 2'),
                  SizedBox(width: 10),
                  TagChip(label: 'Mặt hàng 3'),
                  SizedBox(width: 10),
                  TagChip(label: 'Mặt hàng 4'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Tên mặt hàng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Giá',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Thêm mặt hàng (tùy chỉnh hành động tại đây)
              },
              child: const Text('Thêm mặt hàng'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Thông tin cá nhân'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
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
                  Navigator.pop(context);
                  setState(() {
                    isLoggedIn = false;
                  });
                },
              ),
            ],
          ),
    );
  }
}

// Chip Widget
class TagChip extends StatelessWidget {
  final String label;
  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), backgroundColor: Colors.indigo.shade100);
  }
}
