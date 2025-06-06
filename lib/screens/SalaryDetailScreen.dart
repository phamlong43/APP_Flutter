import 'package:flutter/material.dart';

class SalaryDetailScreen extends StatelessWidget {
  const SalaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Lương Chi Tiết Nhân Viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back_ios, size: 18),
                const Text('04/2021', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRow('Mã nhân viên', 'S1_00050'),
                _buildRow('Họ tên', 'Nguyễn Chí Thanh'),
                _buildRow('Tên phòng ban', 'Bộ Phận Marketing'),
                _buildRow('Lương hợp đồng', '30,000,000'),
                _buildRow('Lương bảo hiểm', '0'),
                _buildRow('Lương cơ bản', '4,000,000'),
                _buildRow('Lương KPI', '4,080,000'),
                _buildRow('Chuyên cần', '1,020,000'),
                _buildRow('Ngày công chuẩn', '24'),
                _buildRow('Ngày đi làm', '20.48'),
                _buildRow('Ngày công tác', '0'),
                _buildRow('Nghỉ phép có lương', '0'),
                _buildRow('Nghỉ phép không lương', '1.5'),
                _buildRow('Ngày nghỉ lễ', '2'),
                _buildRow('Ngày tăng ca', '0'),
                _buildRow('Tổng ngày công', '22.48'),
                _buildRow('Lương theo ngày công', '9,554,000'),
                _buildRow('Khen thưởng tháng', '0'),
                _buildRow('Phạt không báo cáo công việc', '0'),
                _buildRow('Phụ cấp gửi xe', '100,000'),
                _buildRow('Truy lĩnh', ''),
                _buildRow('Truy thu', ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
