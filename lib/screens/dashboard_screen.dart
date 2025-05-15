import 'package:flutter/material.dart';
import 'employee_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Xem danh sách nhân viên'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
            );
          },
        ),
      ),
    );
  }
}
