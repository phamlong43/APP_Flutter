import 'package:flutter/material.dart';
import '../models/employee.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  static const List<Employee> employees = [
    Employee(
      id: '1',
      name: 'Nguyễn Văn A',
      position: 'Quản lý',
      email: 'a@example.com',
    ),
    Employee(
      id: '2',
      name: 'Trần Thị B',
      position: 'Kế toán',
      email: 'b@example.com',
    ),
    Employee(
      id: '3',
      name: 'Lê Văn C',
      position: 'Nhân viên',
      email: 'c@example.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách nhân viên')),
      body: ListView.separated(
        itemCount: employees.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final employee = employees[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                employee.name[0],
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              employee.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${employee.position}\n${employee.email}',
              style: const TextStyle(height: 1.3),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeDetailScreen(employee: employee),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
