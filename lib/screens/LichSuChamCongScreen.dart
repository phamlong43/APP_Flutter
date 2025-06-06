import 'package:flutter/material.dart';

class LichSuChamCongScreen extends StatelessWidget {
  const LichSuChamCongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> attendanceLogs = [
      {'date': '01/06/2024', 'checkIn': '08:00', 'checkOut': '17:00'},
      {'date': '02/06/2024', 'checkIn': '08:15', 'checkOut': '17:10'},
      {'date': '03/06/2024', 'checkIn': '08:05', 'checkOut': '17:05'},
      {'date': '04/06/2024', 'checkIn': '08:20', 'checkOut': '16:55'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Chấm Công'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: attendanceLogs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = attendanceLogs[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('Ngày: ${item['date']}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Vào: ${item['checkIn']}  -  Ra: ${item['checkOut']}'),
              trailing: const Icon(Icons.access_time),
            ),
          );
        },
      ),
    );
  }
}
