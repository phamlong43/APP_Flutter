import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const EmployeeCard({super.key, required this.employee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(employee.name),
      subtitle: Text(employee.position),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
