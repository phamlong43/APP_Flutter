import 'package:flutter/material.dart';
import '../models/employee.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                
                const SizedBox(height: 30),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                
                // Các nút hành động dành cho admin
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.security),
                        label: const Text('Thêm yếu tố xác thực'),
                        onPressed: () {
                          _showAddAuthenticationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payments),
                        label: const Text('Điều chỉnh lương'),
                        onPressed: () {
                          _showSalaryAdjustmentDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Dialog để thêm yếu tố xác thực
  void _showAddAuthenticationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm yếu tố xác thực'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Chọn phương thức xác thực để tăng cường bảo mật và xác minh danh tính cho nhân viên này:',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.fingerprint, color: Colors.blue),
                title: const Text('Vân tay'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to fingerprint setup screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển: Thiết lập vân tay')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.face, color: Colors.purple),
                title: const Text('Nhận diện khuôn mặt'),
                onTap: () async {
                  Navigator.pop(context);
                  _registerFaceAuthentication(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.orange),
                title: const Text('Nhận diện giọng nói'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to voice recognition setup screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển: Thiết lập nhận diện giọng nói')),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Dialog để điều chỉnh lương
  void _showSalaryAdjustmentDialog(BuildContext context) {
    final TextEditingController basicSalaryController = TextEditingController();
    final TextEditingController allowanceController = TextEditingController();
    final TextEditingController bonusController = TextEditingController();
    final TextEditingController deductionController = TextEditingController();
    final TextEditingController overtimeSalaryController = TextEditingController();
    final TextEditingController hourlyRateController = TextEditingController();
    String selectedMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    String selectedStatus = 'pending';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điều chỉnh lương'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nhân viên: ${employee.fullName}', 
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tháng năm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                value: selectedMonth,
                items: _generateMonthYearOptions(),
                onChanged: (value) {
                  if (value != null) {
                    selectedMonth = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: basicSalaryController,
                decoration: const InputDecoration(
                  labelText: 'Lương cơ bản',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'VND',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: allowanceController,
                decoration: const InputDecoration(
                  labelText: 'Phụ cấp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                  hintText: 'VND',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: bonusController,
                decoration: const InputDecoration(
                  labelText: 'Thưởng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard),
                  hintText: 'VND',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: deductionController,
                decoration: const InputDecoration(
                  labelText: 'Khấu trừ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money_off),
                  hintText: 'VND',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: overtimeSalaryController,
                decoration: const InputDecoration(
                  labelText: 'Lương làm thêm giờ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  hintText: 'VND',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Lương mỗi giờ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'VND/giờ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                value: selectedStatus,
                items: const [
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('Chờ duyệt'),
                  ),
                  DropdownMenuItem(
                    value: 'approved',
                    child: Text('Đã duyệt'),
                  ),
                  DropdownMenuItem(
                    value: 'rejected',
                    child: Text('Từ chối'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Gửi yêu cầu PUT để cập nhật thông tin lương
              await _updateSalary(
                context,
                basicSalary: basicSalaryController.text,
                allowance: allowanceController.text,
                bonus: bonusController.text,
                deduction: deductionController.text,
                overtimeSalary: overtimeSalaryController.text,
                hourlyRate: hourlyRateController.text,
                monthYear: selectedMonth,
                status: selectedStatus,
              );
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  // Tạo danh sách các tháng gần đây để chọn
  List<DropdownMenuItem<String>> _generateMonthYearOptions() {
    List<DropdownMenuItem<String>> items = [];
    final now = DateTime.now();
    
    // Thêm tháng hiện tại và 11 tháng trước đó
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i);
      final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      items.add(DropdownMenuItem(
        value: monthYear,
        child: Text(monthYear),
      ));
    }
    
    return items;
  }

  // Gửi yêu cầu cập nhật lương
  Future<void> _updateSalary(
    BuildContext context, {
    required String basicSalary,
    required String allowance,
    required String bonus,
    required String deduction,
    required String overtimeSalary,
    required String hourlyRate,
    required String monthYear,
    required String status,
  }) async {
    try {
      // Hiển thị dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang cập nhật thông tin lương...'),
              ],
            ),
          );
        },
      );

      // Danh sách endpoints để thử kết nối
      final endpointsToTry = [
        'http://localhost:8080/api/salaries/${employee.id}',
        'http://10.0.2.2:8080/api/salaries/${employee.id}',
        'http://127.0.0.1:8080/api/salaries/${employee.id}',
      ];
      
      // Parse các giá trị số
      final basicSalaryValue = int.tryParse(basicSalary) ?? 0;
      final allowanceValue = int.tryParse(allowance) ?? 0;
      final bonusValue = int.tryParse(bonus) ?? 0;
      final deductionValue = int.tryParse(deduction) ?? 0;
      final overtimeSalaryValue = int.tryParse(overtimeSalary) ?? 0;
      final hourlyRateValue = int.tryParse(hourlyRate) ?? 0;
      
      final Map<String, dynamic> requestBody = {
        "user": {"id": employee.id},
        "monthYear": monthYear,
        "basicSalary": basicSalaryValue,
        "allowance": allowanceValue,
        "bonus": bonusValue,
        "deduction": deductionValue,
        "overtimeSalary": overtimeSalaryValue,
        "status": status,
        "hourly_rate": hourlyRateValue
      };
      
      print('DEBUG: Updating salary for employee: ${employee.fullName}, ID: ${employee.id}');
      print('DEBUG: Request body: ${jsonEncode(requestBody)}');
      
      bool success = false;
      String errorMessage = '';
      
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Sending salary update request to: $endpoint');
          
          final response = await http.put(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          ).timeout(const Duration(seconds: 10));
          
          print('DEBUG: Salary update response status: ${response.statusCode}');
          print('DEBUG: Salary update response body: ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
            success = true;
            break;
          } else {
            errorMessage = 'Mã lỗi: ${response.statusCode}';
            if (response.body.isNotEmpty) {
              try {
                final errorBody = jsonDecode(response.body);
                errorMessage += ' - ${errorBody['message'] ?? errorBody.toString()}';
              } catch (e) {
                errorMessage += ' - ${response.body}';
              }
            }
          }
        } catch (e) {
          print('DEBUG: Failed to update salary with endpoint $endpoint: $e');
          errorMessage = e.toString();
          continue;
        }
      }
      
      // Đóng dialog loading
      Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin lương thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật lương: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Đảm bảo dialog loading được đóng nếu có lỗi
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Gửi yêu cầu đăng ký xác thực khuôn mặt
  Future<void> _registerFaceAuthentication(BuildContext context) async {
    try {
      // Hiển thị dialog loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang gửi yêu cầu đăng ký xác thực...'),
              ],
            ),
          );
        },
      );

      // Danh sách endpoints để thử kết nối
      final endpointsToTry = [
        'http://localhost:8080/api/face-register-requests',
        'http://10.0.2.2:8080/api/face-register-requests',
        'http://127.0.0.1:8080/api/face-register-requests',
      ];
      
      // Lấy userId từ employee object
      final userId = employee.id; 
      bool success = false;
      String errorMessage = '';
      
      print('DEBUG: Registering face authentication for employee: ${employee.fullName}, ID: $userId');
      
      for (String endpoint in endpointsToTry) {
        try {
          final url = '$endpoint?userId=$userId';
          print('DEBUG: Sending face registration request to: $url');
          
          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));
          
          print('DEBUG: Face registration response status: ${response.statusCode}');
          print('DEBUG: Face registration response body: ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            success = true;
            break;
          } else {
            errorMessage = 'Mã lỗi: ${response.statusCode}';
          }
        } catch (e) {
          print('DEBUG: Failed to register face with endpoint $endpoint: $e');
          errorMessage = e.toString();
          continue;
        }
      }
      
      // Đóng dialog loading
      Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yêu cầu đăng ký xác thực khuôn mặt đã được gửi thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi yêu cầu đăng ký: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Đảm bảo dialog loading được đóng nếu có lỗi
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
