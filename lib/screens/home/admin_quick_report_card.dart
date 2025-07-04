import 'package:flutter/material.dart';

class AdminQuickReportCard extends StatelessWidget {
  final int totalUsers;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int onLeaveUsers;
  final VoidCallback onTap;

  const AdminQuickReportCard({
    super.key,
    required this.totalUsers,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.onLeaveUsers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: Colors.purple,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Báo cáo nhanh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Dữ liệu báo cáo
              _buildReportRow(
                'Tổng nhân viên',
                '$totalUsers',
                Icons.people,
                Colors.blue,
              ),
              _buildReportRow(
                'Đang nghỉ phép',
                '$onLeaveUsers',
                Icons.beach_access,
                Colors.orange,
              ),
              _buildReportRow(
                'Nhiệm vụ hoàn thành',
                '$completedTasks/$totalTasks',
                Icons.assignment_turned_in,
                Colors.green,
              ),
              _buildReportRow(
                'Quá hạn',
                '$overdueTasks',
                Icons.assignment_late,
                Colors.red,
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Xem chi tiết >>',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
