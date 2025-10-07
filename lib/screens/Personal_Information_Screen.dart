import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Thông tin cá nhân
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  // Controllers cho các trường nhập liệu
  final TextEditingController employeeCodeController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController idIssuedPlaceController = TextEditingController();
  final TextEditingController idIssuedDateController = TextEditingController();
  final TextEditingController ethnicityController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController permanentAddressController = TextEditingController();
  final TextEditingController temporaryAddressController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController workStatusController = TextEditingController();

  String gender = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  @override
  void dispose() {
    // Giải phóng controller
    employeeCodeController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    placeOfBirthController.dispose();
    idNumberController.dispose();
    idIssuedPlaceController.dispose();
    idIssuedDateController.dispose();
    ethnicityController.dispose();
    religionController.dispose();
    nationalityController.dispose();
    maritalStatusController.dispose();
    educationController.dispose();
    permanentAddressController.dispose();
    temporaryAddressController.dispose();
    departmentController.dispose();
    positionController.dispose();
    workStatusController.dispose();
    super.dispose();
  }

  Future<void> fetchUserInfo() async {
    // TODO: Thay userId bằng id thực tế của user đang đăng nhập
    const userId = '1';
    final url = Uri.parse('${ApiConfig.userEndpoint}/$userId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          userInfo = jsonDecode(response.body);
          // Gán dữ liệu vào controller
          employeeCodeController.text = userInfo['employeeCode'] ?? '';
          fullNameController.text = userInfo['fullName'] ?? '';
          gender = userInfo['gender'] ?? '';
          mobileController.text = userInfo['mobile'] ?? '';
          emailController.text = userInfo['email'] ?? '';
          phoneController.text = userInfo['phone'] ?? '';
          dateOfBirthController.text = userInfo['dateOfBirth'] ?? '';
          placeOfBirthController.text = userInfo['placeOfBirth'] ?? '';
          idNumberController.text = userInfo['idNumber'] ?? '';
          idIssuedPlaceController.text = userInfo['idIssuedPlace'] ?? '';
          idIssuedDateController.text = userInfo['idIssuedDate'] ?? '';
          ethnicityController.text = userInfo['ethnicity'] ?? '';
          religionController.text = userInfo['religion'] ?? '';
          nationalityController.text = userInfo['nationality'] ?? '';
          maritalStatusController.text = userInfo['maritalStatus'] ?? '';
          educationController.text = userInfo['education'] ?? '';
          permanentAddressController.text = userInfo['permanentAddress'] ?? '';
          temporaryAddressController.text = userInfo['temporaryAddress'] ?? '';
          departmentController.text = userInfo['department'] ?? '';
          positionController.text = userInfo['position'] ?? '';
          workStatusController.text = userInfo['workStatus'] ?? '';
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/user1.png'),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullNameController.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(employeeCodeController.text, style: const TextStyle(color: Colors.red)),
                            Text((departmentController.text) + (positionController.text.isNotEmpty ? '\n${positionController.text}' : '')),
                            const SizedBox(height: 8),
                            if ((workStatusController.text).isNotEmpty)
                              Chip(
                                label: Text(workStatusController.text, style: const TextStyle(color: Colors.white)),
                                backgroundColor: Colors.green,
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(label: 'Mã nhân viên', controller: employeeCodeController),
                    _buildInputField(label: 'Họ và tên', controller: fullNameController),
                    _buildDropdown(label: 'Giới tính', value: gender, items: ['Nam', 'Nữ'], onChanged: (val) { setState(() { gender = val ?? ''; }); }),
                    _buildInputField(label: 'SĐT di động', controller: mobileController),
                    _buildInputField(label: 'Email', controller: emailController),
                    _buildInputField(label: 'Điện thoại bàn', controller: phoneController),
                    const Divider(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Thông tin thêm', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(label: 'Ngày sinh', controller: dateOfBirthController),
                    _buildInputField(label: 'Nơi sinh', controller: placeOfBirthController),
                    _buildInputField(label: 'Số CMND/CCCD', controller: idNumberController),
                    _buildInputField(label: 'Nơi cấp CMND/CCCD', controller: idIssuedPlaceController),
                    _buildInputField(label: 'Ngày cấp CMND/CCCD', controller: idIssuedDateController),
                    _buildInputField(label: 'Dân tộc', controller: ethnicityController),
                    _buildInputField(label: 'Tôn giáo', controller: religionController),
                    _buildInputField(label: 'Quốc tịch', controller: nationalityController),
                    _buildInputField(label: 'Tình trạng hôn nhân', controller: maritalStatusController),
                    _buildInputField(label: 'Học vấn', controller: educationController),
                    _buildInputField(label: 'Địa chỉ thường trú', controller: permanentAddressController),
                    _buildInputField(label: 'Địa chỉ tạm trú', controller: temporaryAddressController),
                    _buildInputField(label: 'Bộ phận/phòng ban', controller: departmentController),
                    _buildInputField(label: 'Chức vụ', controller: positionController),
                    _buildInputField(label: 'Trạng thái làm việc', controller: workStatusController),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(onPressed: () {}, child: const Text('Lịch Sử')),
            OutlinedButton(onPressed: () {}, child: const Text('Lưu Thay Đổi')),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Gửi Duyệt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, TextEditingController? controller, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }
}
