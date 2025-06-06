import 'package:flutter/material.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> documents = [
      {
        'title': 'Quy định nghỉ phép',
        'description': 'Chi tiết quy định về việc nghỉ phép trong công ty.',
        'file': 'quydinh_nghiphep.pdf'
      },
      {
        'title': 'Chính sách bảo hiểm',
        'description': 'Tài liệu hướng dẫn các chế độ bảo hiểm cho nhân viên.',
        'file': 'chinh_sach_baohiem.pdf'
      },
      {
        'title': 'Nội quy lao động',
        'description': 'Nội quy làm việc tại công ty.',
        'file': 'noiquy_laodong.pdf'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài liệu công ty'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            title: Text(doc['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(doc['description']!),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Demo: bạn có thể mở trang chi tiết hoặc tải file nếu có backend
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở tài liệu: ${doc['file']}')),
              );
            },
          );
        },
      ),
    );
  }
}
