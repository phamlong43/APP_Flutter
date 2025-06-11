import 'package:flutter/material.dart';

class AdminStatCards extends StatelessWidget {
  final bool isLoadingUsers;
  final int userCount;
  final int taskCount;
  final VoidCallback onUserTap;
  final VoidCallback onTaskTap;
  final VoidCallback onApprovalTap;

  const AdminStatCards({
    super.key,
    required this.isLoadingUsers,
    required this.userCount,
    required this.taskCount,
    required this.onUserTap,
    required this.onTaskTap,
    required this.onApprovalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          Icons.groups, 'Nhân sự', Colors.blue, isLoadingUsers ? '...' : userCount.toString(),
          onTap: onUserTap,
        ),
        _buildStatCard(
          Icons.assignment_turned_in, 'Nhiệm vụ', Colors.orange, taskCount.toString(),
          onTap: onTaskTap,
        ),
        _buildStatCard(
          Icons.approval, 'Chờ duyệt', Colors.red, '7',
          onTap: onApprovalTap,
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, Color color, String value, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
