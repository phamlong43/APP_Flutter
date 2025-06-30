import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dữ liệu mẫu, bạn có thể thay bằng API thực tế
  final List<Map<String, String>> notifications = [
    {
      'type': 'task',
      'title': 'Bạn được giao nhiệm vụ mới',
      'content': 'Admin đã giao nhiệm vụ: Báo cáo tuần',
      'time': '10:30 30/06/2025',
    },
    {
      'type': 'reward',
      'title': 'Khen thưởng',
      'content': 'Bạn được khen thưởng: Nhân viên xuất sắc tháng 6',
      'time': '09:00 28/06/2025',
    },
    {
      'type': 'discipline',
      'title': 'Kỷ luật',
      'content': 'Bạn bị nhắc nhở: Đi muộn ngày 25/06',
      'time': '17:00 25/06/2025',
    },
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment_turned_in;
      case 'reward':
        return Icons.emoji_events;
      case 'discipline':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'task':
        return Colors.blue;
      case 'reward':
        return Colors.green;
      case 'discipline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.blue,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Không có thông báo nào.'))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(n['type'] ?? ''),
                    child: Icon(_getIcon(n['type'] ?? ''), color: Colors.white),
                  ),
                  title: Text(n['title'] ?? ''),
                  subtitle: Text(n['content'] ?? ''),
                  trailing: Text(
                    n['time'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
