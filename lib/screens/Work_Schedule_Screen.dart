import 'package:flutter/material.dart';

class WorkScheduleScreen extends StatelessWidget {
  const WorkScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleData = [
      {
        'date': 'Thứ 2, 20/05',
        'shift': '08:00 - 17:00',
        'status': 'Đã chấm công',
        'color': Colors.green
      },
      {
        'date': 'Thứ 3, 21/05',
        'shift': '08:00 - 17:00',
        'status': 'Chưa chấm công',
        'color': Colors.red
      },
      {
        'date': 'Thứ 4, 22/05',
        'shift': 'Nghỉ',
        'status': 'Nghỉ phép',
        'color': Colors.orange
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Làm Việc'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: scheduleData.length,
        itemBuilder: (context, index) {
          final item = scheduleData[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: item['color']),
              title: Text(item['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Ca: ${item['shift']}\nTrạng thái: ${item['status']}'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
