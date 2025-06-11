import 'package:flutter/material.dart';

class AdminQuickReportCard extends StatelessWidget {
  final VoidCallback onTap;
  final int totalUsers;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int onLeaveUsers;
  const AdminQuickReportCard({
    super.key,
    required this.onTap,
    required this.totalUsers,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.onLeaveUsers,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BÁO CÁO THỐNG KÊ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue)),
              const SizedBox(height: 14),
              _buildStatRow('Tổng số nhân viên', totalUsers),
              _buildStatRow('Số nhân viên nghỉ phép', onLeaveUsers),
              _buildStatRow('Số nhiệm vụ hoàn thành', completedTasks),
              _buildStatRow('Số nhiệm vụ trễ hạn', overdueTasks),
              _buildStatRow('Tổng số nhiệm vụ', totalTasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
