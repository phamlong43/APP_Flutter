import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông tin: ${employee.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${employee.id}'),
            Text('Tên: ${employee.name}'),
            Text('Chức vụ: ${employee.position}'),
            Text('Email: ${employee.email}'),
          ],
        ),
      ),
    );
  }
}
