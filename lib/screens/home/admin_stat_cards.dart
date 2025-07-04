import 'package:flutter/material.dart';

class AdminStatCards extends StatelessWidget {
  final bool isLoadingUsers;
  final VoidCallback onUserTap;
  final VoidCallback onTaskTap;
  final VoidCallback onApprovalTap;

  const AdminStatCards({
    super.key,
    required this.isLoadingUsers,
    required this.onUserTap,
    required this.onTaskTap,
    required this.onApprovalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card nhân viên
        Expanded(
          child: _buildStatCard(
            context,
            Icons.people,
            'Nhân viên',
            isLoadingUsers ? '...' : '30+',
            Colors.blue,
            onUserTap,
          ),
        ),
        const SizedBox(width: 12),
        // Card nhiệm vụ
        Expanded(
          child: _buildStatCard(
            context,
            Icons.assignment,
            'Nhiệm vụ',
            '64+',
            Colors.green,
            onTaskTap,
          ),
        ),
        const SizedBox(width: 12),
        // Card phê duyệt
        Expanded(
          child: _buildStatCard(
            context,
            Icons.approval,
            'Phê duyệt',
            '12',
            Colors.orange,
            onApprovalTap,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
