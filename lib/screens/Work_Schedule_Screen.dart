import 'package:flutter/material.dart';

class WorkScheduleScreen extends StatelessWidget {
  const WorkScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> schedule = [
      {
        'date': 'Thứ 2 - 20/05/2024',
        'shift': 'Ca sáng',
        'status': 'Đã chấm công',
        'color': Colors.green,
      },
      {
        'date': 'Thứ 3 - 21/05/2024',
        'shift': 'Ca chiều',
        'status': 'Chưa chấm công',
        'color': Colors.orange,
      },
      {
        'date': 'Thứ 4 - 22/05/2024',
        'shift': 'Nghỉ',
        'status': 'Không làm việc',
        'color': Colors.grey,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Làm Việc'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final item = schedule[index];
          final String date = item['date'] as String;
          final String shift = item['shift'] as String;
          final String status = item['status'] as String;
          final Color color = item['color'] as Color;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(date),
              subtitle: Text('$shift - $status'),
              tileColor: color.withOpacity(0.1),
              leading: Icon(Icons.calendar_today, color: color),
            ),
          );
        },
      ),
    );
  }
}
