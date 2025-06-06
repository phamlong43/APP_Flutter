// ChamCongHoScreen.dart
import 'package:flutter/material.dart';

class ChamCongHoScreen extends StatelessWidget {
  const ChamCongHoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final proxyLogs = [
      {'name': 'Nguyễn Văn A', 'date': '01/06/2024', 'status': 'Đã chấm công hộ'},
      {'name': 'Trần Thị B', 'date': '02/06/2024', 'status': 'Đã chấm công hộ'},
      {'name': 'Lê Văn C', 'date': '03/06/2024', 'status': 'Chờ xác nhận'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm Công Hộ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: proxyLogs.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final log = proxyLogs[index];
          return ListTile(
            leading: const Icon(Icons.person_pin_circle, color: Colors.teal),
            title: Text(log['name']!),
            subtitle: Text('${log['date']} - ${log['status']}'),
            trailing: Icon(
              log['status'] == 'Đã chấm công hộ' ? Icons.check_circle : Icons.hourglass_top,
              color: log['status'] == 'Đã chấm công hộ' ? Colors.green : Colors.orange,
            ),
          );
        },
      ),
    );
  }
}