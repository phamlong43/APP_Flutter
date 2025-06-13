import 'package:flutter/material.dart';
import '../components/admin_stat_cards.dart';
import '../components/admin_quick_report_card.dart';
import '../components/admin_recent_activity_card.dart';
import '../components/user_requests_widget.dart';
import '../components/icon_tile.dart';

class HomeMainContent extends StatelessWidget {
  final bool isAdmin;
  final String username;
  final List<dynamic> users;
  final List<Map<String, dynamic>> tasks;
  final bool isLoadingUsers;
  final int selectedIndex;
  final Function(int) onNavTap;
  const HomeMainContent({
    Key? key,
    required this.isAdmin,
    required this.username,
    required this.users,
    required this.tasks,
    required this.isLoadingUsers,
    required this.selectedIndex,
    required this.onNavTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tùy chỉnh nội dung chính ở đây, ví dụ:
    if (isAdmin) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thống kê nhanh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            AdminStatCards(
              isLoadingUsers: isLoadingUsers,
              onUserTap: () {},
              onTaskTap: () {},
              onApprovalTap: () {},
            ),
            const SizedBox(height: 24),
            AdminQuickReportCard(
              onTap: () {},
              totalUsers: users.length,
              totalTasks: tasks.length,
              completedTasks: tasks.where((t) => t['status'] == 'completed').length,
              overdueTasks: tasks.where((t) => t['status'] == 'overdue').length,
              onLeaveUsers: users.where((u) => (u['work_status'] ?? '').toLowerCase().contains('nghỉ')).length,
            ),
            const SizedBox(height: 24),
            const AdminRecentActivityCard(),
          ],
        ),
      );
    }
    // Giao diện cho user thường
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: UserRequestsWidget(username: username),
        ),
        // ...các widget khác như IconTile, v.v.
      ],
    );
  }
}
