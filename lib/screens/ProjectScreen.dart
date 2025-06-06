// ProjectScreen.dart
import 'package:flutter/material.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      {
        'title': 'Triển khai App HRM',
        'deadline': '30/06/2024',
        'status': 'Đang thực hiện',
        'team': 'Phát triển'
      },
      {
        'title': 'Tuyển dụng Thực tập sinh Marketing',
        'deadline': '15/06/2024',
        'status': 'Đã hoàn thành',
        'team': 'Nhân sự'
      },
      {
        'title': 'Thiết kế tài liệu nội bộ',
        'deadline': '10/07/2024',
        'status': 'Chưa bắt đầu',
        'team': 'Truyền thông'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Dự Án'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final p = projects[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined, color: Colors.indigo),
              title: Text(p['title']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hạn: ${p['deadline']}'),
                  Text('Nhóm: ${p['team']}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p['status']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
