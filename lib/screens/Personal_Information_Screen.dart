import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  String gender = 'Nam';
  String maritalStatus = 'Độc thân';
  String education = 'Đại học';
  String nationality = 'Việt Nam';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Cá Nhân'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
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
                    children: const [
                      Text('NGUYỄN VĂN NAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('S1_00050', style: TextStyle(color: Colors.red)),
                      Text('Bộ phận Marketing\nTrưởng phòng'),
                      SizedBox(height: 8),
                      Chip(
                        label: Text('Đang làm việc', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInputField(label: 'Mã nhân viên', initialValue: 'S1_00050', enabled: false),
              _buildInputField(label: 'Họ và tên', initialValue: 'Nguyễn Văn Nam'),
              _buildDropdown(label: 'Giới tính', value: gender, items: ['Nam', 'Nữ'], onChanged: (val) {
                setState(() => gender = val!);
              }),
              _buildInputField(label: 'SĐT di động', initialValue: '0901909195'),
              _buildInputField(label: 'Email', initialValue: 'nam.nguyen@hror'),
              _buildInputField(label: 'Điện thoại bàn'),
              const Divider(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Thông tin thêm', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              _buildInputField(label: 'Ngày sinh', initialValue: '14/05/2003'),
              _buildInputField(label: 'Nơi sinh', initialValue: 'Hà Tây'),
              _buildInputField(label: 'Số CMND', initialValue: '331655196'),
              _buildInputField(label: 'Nơi cấp CMND', initialValue: 'Hà Tây'),
              _buildInputField(label: 'Ngày cấp CMND', initialValue: '14/03/2021'),
              _buildDropdown(label: 'Dân tộc', value: 'Kinh', items: ['Kinh', 'Khác'], onChanged: (_) {}),
              _buildDropdown(label: 'Tôn giáo', value: 'Không có', items: ['Không có', 'Khác'], onChanged: (_) {}),
              _buildDropdown(label: 'Quốc tịch', value: nationality, items: ['Việt Nam', 'Khác'], onChanged: (val) {
                setState(() => nationality = val!);
              }),
              const SizedBox(height: 16),
              _buildMaritalStatusSelector(),
              _buildDropdown(label: 'Học vấn', value: education, items: ['Đại học', 'Cao đẳng', 'THPT'], onChanged: (val) {
                setState(() => education = val!);
              }),
              _buildInputField(label: 'Địa chỉ thường trú', initialValue: 'Vĩnh Long'),
              _buildInputField(label: 'Địa chỉ tạm trú', initialValue: 'Hồ Chí Minh'),
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

  Widget _buildInputField({required String label, String? initialValue, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
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
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  Widget _buildMaritalStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tình trạng hôn nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: RadioListTile(value: 'Độc thân', groupValue: maritalStatus, onChanged: (val) => setState(() => maritalStatus = val!), title: const Text('Độc thân'))),
            Expanded(child: RadioListTile(value: 'Có gia đình', groupValue: maritalStatus, onChanged: (val) => setState(() => maritalStatus = val!), title: const Text('Có gia đình'))),
            Expanded(child: RadioListTile(value: 'Ly hôn', groupValue: maritalStatus, onChanged: (val) => setState(() => maritalStatus = val!), title: const Text('Ly hôn'))),
          ],
        ),
      ],
    );
  }
}
