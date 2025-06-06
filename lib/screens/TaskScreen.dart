import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Lập kế hoạch sự kiện cuối năm',
        'description': 'Chuẩn bị và phân bổ nhân sự cho sự kiện ngày 20/12',
        'status': 'Đang thực hiện',
        'priority': 'Cao',
      },
      {
        'title': 'Kiểm tra thiết bị văn phòng',
        'description': 'Xác nhận tình trạng các thiết bị và báo cáo phòng IT',
        'status': 'Hoàn thành',
        'priority': 'Trung bình',
      },
      {
        'title': 'Họp đánh giá nhân sự',
        'description': 'Tham gia họp với trưởng phòng để đánh giá định kỳ',
        'status': 'Chưa bắt đầu',
        'priority': 'Thấp',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Nhiệm Vụ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(task['description']),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(task['status']),
                        backgroundColor: _statusColor(task['status']),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('Ưu tiên: ${task['priority']}'),
                        backgroundColor: _priorityColor(task['priority']),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Điều hướng đến chi tiết nhiệm vụ nếu cần
              },
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
        return Colors.green.shade100;
      case 'Đang thực hiện':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Cao':
        return Colors.red.shade100;
      case 'Trung bình':
        return Colors.yellow.shade100;
      default:
        return Colors.blue.shade100;
    }
  }
}
