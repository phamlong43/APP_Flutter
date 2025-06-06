import 'package:flutter/material.dart';

class RecruitmentScreen extends StatelessWidget {
  const RecruitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobList = [
      {
        'position': 'Nhân viên Kế toán',
        'department': 'Phòng Tài chính',
        'deadline': '30/06/2024'
      },
      {
        'position': 'Lập trình viên Mobile',
        'department': 'Phòng Công nghệ',
        'deadline': '15/07/2024'
      },
      {
        'position': 'Chuyên viên Tuyển dụng',
        'department': 'Phòng Nhân sự',
        'deadline': '10/07/2024'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuyển Dụng'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: jobList.length,
        itemBuilder: (context, index) {
          final job = jobList[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.work_outline, color: Colors.indigo),
              title: Text(job['position']!),
              subtitle: Text(
                '${job['department']} • Hạn nộp: ${job['deadline']}',
              ),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng ứng tuyển đang được phát triển.')),
                  );
                },
                child: const Text('Ứng tuyển'),
              ),
            ),
          );
        },
      ),
    );
  }
}
