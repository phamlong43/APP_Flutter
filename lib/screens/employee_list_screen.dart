import 'package:flutter/material.dart';
import 'employee_detail_screen.dart';
import '../models/employee.dart';

class EmployeeListScreen extends StatelessWidget {
  final List<dynamic> users;
  const EmployeeListScreen({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách nhân sự')),
      body: users.isEmpty
          ? const Center(child: Text('Không có dữ liệu nhân sự'))
          : ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final user = users[i];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['full_name'] ?? ''),
                  subtitle: Text('Phòng: ${user['department'] ?? ''} | Chức vụ: ${user['position'] ?? ''}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeDetailScreen(
                          employee: Employee(
                            id: (user['id'] ?? '').toString(),
                            employeeCode: user['employee_code'] ?? '',
                            fullName: user['full_name'] ?? '',
                            position: user['position'] ?? '',
                            department: user['department'] ?? '',
                            email: user['email'] ?? '',
                            gender: user['gender'],
                            dateOfBirth: user['date_of_birth'],
                            placeOfBirth: user['place_of_birth'],
                            nationality: user['nationality'],
                            ethnicity: user['ethnicity'],
                            religion: user['religion'],
                            maritalStatus: user['marital_status'],
                            education: user['education'],
                            idNumber: user['id_number'],
                            idIssuedPlace: user['id_issued_place'],
                            idIssuedDate: user['id_issued_date']?.toString(),
                            permanentAddress: user['permanent_address'],
                            temporaryAddress: user['temporary_address'],
                            address: user['address'],
                            phone: user['phone'],
                            mobile: user['mobile'],
                            workStatus: user['work_status'],
                            createdAt: user['created_at'],
                            updatedAt: user['updated_at'],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
