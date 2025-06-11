import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin nhân viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    employee.fullName.isNotEmpty ? employee.fullName.substring(0, 1).toUpperCase() : '',
                    style: const TextStyle(fontSize: 40, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  employee.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  employee.position,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(height: 32, thickness: 1),
                _buildInfoRow(Icons.badge, 'Mã nhân viên', employee.employeeCode),
                _buildInfoRow(Icons.person, 'Họ tên', employee.fullName),
                _buildInfoRow(Icons.cake, 'Ngày sinh', employee.dateOfBirth ?? ''),
                _buildInfoRow(Icons.male, 'Giới tính', employee.gender ?? ''),
                _buildInfoRow(Icons.school, 'Trình độ học vấn', employee.education ?? ''),
                _buildInfoRow(Icons.email, 'Email', employee.email),
                _buildInfoRow(Icons.phone, 'Số điện thoại', employee.phone ?? ''),
                _buildInfoRow(Icons.phone_android, 'Di động', employee.mobile ?? ''),
                _buildInfoRow(Icons.apartment, 'Phòng ban', employee.department),
                _buildInfoRow(Icons.business_center, 'Chức vụ', employee.position),
                _buildInfoRow(Icons.flag, 'Quốc tịch', employee.nationality ?? ''),
                _buildInfoRow(Icons.group, 'Dân tộc', employee.ethnicity ?? ''),
                _buildInfoRow(Icons.account_balance, 'Tôn giáo', employee.religion ?? ''),
                _buildInfoRow(Icons.family_restroom, 'Tình trạng hôn nhân', employee.maritalStatus ?? ''),
                _buildInfoRow(Icons.home, 'Nơi sinh', employee.placeOfBirth ?? ''),
                _buildInfoRow(Icons.location_on, 'Địa chỉ thường trú', employee.permanentAddress ?? ''),
                _buildInfoRow(Icons.location_city, 'Địa chỉ tạm trú', employee.temporaryAddress ?? ''),
                _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ liên hệ', employee.address ?? ''),
                _buildInfoRow(Icons.credit_card, 'Số CMND/CCCD', employee.idNumber ?? ''),
                _buildInfoRow(Icons.place, 'Nơi cấp', employee.idIssuedPlace ?? ''),
                _buildInfoRow(Icons.date_range, 'Ngày cấp', employee.idIssuedDate ?? ''),
                _buildInfoRow(Icons.verified_user, 'Trạng thái làm việc', employee.workStatus ?? ''),
                _buildInfoRow(Icons.calendar_today, 'Ngày tạo', employee.createdAt ?? ''),
                _buildInfoRow(Icons.update, 'Ngày cập nhật', employee.updatedAt ?? ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
