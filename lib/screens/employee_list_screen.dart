import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'employee_detail_screen.dart';
import '../models/employee.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<dynamic> users = [];
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchUsers());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    if (_loading) return;
    _loading = true;
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/users')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> newUsers = json.decode(response.body);
        if (!listEquals(newUsers, users)) {
          setState(() {
            users = newUsers;
          });
        }
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      _loading = false;
    }
  }

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
