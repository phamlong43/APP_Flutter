import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../widgets/employee_card.dart';
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
      appBar: AppBar(title: const Text('Danh sách nhân sự')),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return EmployeeCard(
            employee: employees[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EmployeeDetailScreen(employee: employees[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
