// EmployeeScreen.dart
import 'package:flutter/material.dart';
import 'employee_list_screen.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chuyển hướng sang EmployeeListScreen động
    return const EmployeeListScreen();
  }
}
