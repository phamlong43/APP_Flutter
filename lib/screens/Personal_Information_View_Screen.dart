import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Personal_Information_Screen.dart';

class PersonalInformationViewScreen extends StatefulWidget {
  final String username;
  const PersonalInformationViewScreen({super.key, required this.username});

  @override
  State<PersonalInformationViewScreen> createState() => _PersonalInformationViewScreenState();
}

class _PersonalInformationViewScreenState extends State<PersonalInformationViewScreen> {
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final username = widget.username;
    final url = Uri.parse('http://10.0.2.2:8080/users/$username');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Cá Nhân'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: const AssetImage('assets/user1.png'),
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userInfo['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(userInfo['employee_code'] ?? '', style: const TextStyle(color: Colors.red, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text((userInfo['department'] ?? '') + ((userInfo['position'] ?? '').isNotEmpty ? '\n${userInfo['position']}' : ''), style: const TextStyle(fontSize: 15)),
                                const SizedBox(height: 8),
                                if ((userInfo['work_status'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(userInfo['work_status'], style: const TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow('Tên đăng nhập', userInfo['username']),
                      _buildInfoRow('Mã nhân viên', userInfo['employee_code']),
                      _buildInfoRow('Họ và tên', userInfo['full_name']),
                      _buildInfoRow('Giới tính', userInfo['gender']),
                      _buildInfoRow('Ngày sinh', userInfo['date_of_birth']),
                      _buildInfoRow('Nơi sinh', userInfo['place_of_birth']),
                      _buildInfoRow('SĐT di động', userInfo['mobile']),
                      _buildInfoRow('Email', userInfo['email']),
                      _buildInfoRow('Điện thoại bàn', userInfo['phone']),
                      _buildInfoRow('Địa chỉ thường trú', userInfo['permanent_address']),
                      _buildInfoRow('Địa chỉ tạm trú', userInfo['temporary_address']),
                      _buildInfoRow('Địa chỉ liên hệ', userInfo['address']),
                      _buildInfoRow('Số CMND/CCCD', userInfo['id_number']),
                      _buildInfoRow('Nơi cấp CMND/CCCD', userInfo['id_issued_place']),
                      _buildInfoRow('Ngày cấp CMND/CCCD', (userInfo['id_issued_date'] != null && userInfo['id_issued_date'].toString().isNotEmpty) ? userInfo['id_issued_date'].toString().split('T').first : ''),
                      _buildInfoRow('Dân tộc', userInfo['ethnicity']),
                      _buildInfoRow('Tôn giáo', userInfo['religion']),
                      _buildInfoRow('Quốc tịch', userInfo['nationality']),
                      _buildInfoRow('Tình trạng hôn nhân', userInfo['marital_status']),
                      _buildInfoRow('Học vấn', userInfo['education']),
                      _buildInfoRow('Bộ phận/phòng ban', userInfo['department']),
                      _buildInfoRow('Chức vụ', userInfo['position']),
                      _buildInfoRow('Trạng thái làm việc', userInfo['work_status']),
                      _buildInfoRow('Quyền', userInfo['role']),
                      const SizedBox(height: 16),
                      const Divider(),
                      _buildInfoRow('Ngày tạo', (userInfo['created_at'] != null && userInfo['created_at'].toString().isNotEmpty) ? userInfo['created_at'].toString().split('T').first : ''),
                      _buildInfoRow('Ngày cập nhật', (userInfo['updated_at'] != null && userInfo['updated_at'].toString().isNotEmpty) ? userInfo['updated_at'].toString().split('T').first : ''),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalInformationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Yêu cầu chỉnh sửa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14))),
          Expanded(child: Text(value ?? '', style: const TextStyle(color: Colors.black, fontSize: 15))),
        ],
      ),
    );
  }
}

// Import trang chỉnh sửa

