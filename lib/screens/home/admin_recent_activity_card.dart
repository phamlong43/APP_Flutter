import 'package:flutter/material.dart';

class AdminRecentActivityCard extends StatelessWidget {
  const AdminRecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data cho hoạt động gần đây
    final activities = [
      {
        'user': 'Nguyễn Văn A',
        'action': 'đã hoàn thành nhiệm vụ',
        'target': 'Báo cáo doanh số Q2',
        'time': '10 phút trước',
        'avatar': 'A',
        'color': Colors.blue,
      },
      {
        'user': 'Trần Thị B',
        'action': 'đã tạo yêu cầu nghỉ phép',
        'target': '3 ngày (12/07 - 14/07)',
        'time': '30 phút trước',
        'avatar': 'B',
        'color': Colors.green,
      },
      {
        'user': 'Lê Văn C',
        'action': 'đã check-in',
        'target': 'Sáng 04/07/2025',
        'time': '2 giờ trước',
        'avatar': 'C',
        'color': Colors.orange,
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hoạt động gần đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.more_horiz),
              ],
            ),
            const Divider(),
            ...activities.map((activity) => _buildActivityItem(context, activity)),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: activity['color'] as Color,
            radius: 16,
            child: Text(
              activity['avatar'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: activity['user'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${activity['action']} '),
                      TextSpan(
                        text: activity['target'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
