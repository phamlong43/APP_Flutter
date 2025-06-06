// EmployeeScreen.dart
import 'package:flutter/material.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = [
      {
        'name': 'Nguyễn Văn A',
        'position': 'Nhân viên Marketing',
        'avatar': 'assets/user1.png',
        'phone': '0123456789',
        'email': 'a@company.com'
      },
      {
        'name': 'Trần Thị B',
        'position': 'Kế toán trưởng',
        'avatar': 'assets/user2.png',
        'phone': '0987654321',
        'email': 'b@company.com'
      },
      {
        'name': 'Lê Văn C',
        'position': 'Lãnh đạo dự án',
        'avatar': 'assets/user3.png',
        'phone': '0111222333',
        'email': 'c@company.com'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Nhân Sự'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final emp = employees[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(emp['avatar']!),
              radius: 24,
            ),
            title: Text(emp['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(emp['position']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => _buildEmployeeDetailSheet(emp),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmployeeDetailSheet(Map<String, String> emp) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(emp['avatar']!),
                radius: 30,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emp['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(emp['position']!),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(emp['phone']!),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(emp['email']!),
          ),
        ],
      ),
    );
  }
}
