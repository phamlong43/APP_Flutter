import 'package:flutter/material.dart';

class AdminRecentActivityCard extends StatelessWidget {
  final VoidCallback onTap;
  const AdminRecentActivityCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hoạt động gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.green),
                title: const Text('Nguyễn Văn A vừa được thêm vào phòng IT'),
                subtitle: const Text('2 phút trước'),
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in, color: Colors.blue),
                title: const Text('Nhiệm vụ "Báo cáo tháng 6" đã hoàn thành'),
                subtitle: const Text('1 giờ trước'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
