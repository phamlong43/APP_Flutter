import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatisticsScreen extends StatelessWidget {
  final int totalUsers;
  final int onLeaveUsers;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tasks;
  const AdminStatisticsScreen({
    super.key,
    required this.totalUsers,
    required this.onLeaveUsers,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.users,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê tổng quan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Bảng thống kê chi tiết
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BẢNG CHỈ SỐ CHI TIẾT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                  const SizedBox(height: 10),
                  _statRow('Tổng số nhân viên', totalUsers),
                  _statRow('Số nhân viên nghỉ phép', onLeaveUsers),
                  _statRow('Số nhân viên đang làm việc', totalUsers - onLeaveUsers),
                  _statRow('Số nhân viên nghỉ việc', users.where((u) => (u['work_status'] ?? '').toLowerCase().contains('nghỉ việc')).length),
                  _statRow('Tổng số nhiệm vụ', totalTasks),
                  _statRow('Số nhiệm vụ hoàn thành', completedTasks),
                  _statRow('Số nhiệm vụ trễ hạn', overdueTasks),
                  _statRow('Số nhiệm vụ đang thực hiện', tasks.where((t) => t['status'] == 'in_progress' || t['status'] == 'doing' || t['status'] == 'Đang thực hiện').length),
                  _statRow('Số nhiệm vụ chưa bắt đầu', tasks.where((t) => t['status'] == 'not_started' || t['status'] == 'Chưa bắt đầu').length),
                  _statRow('Nhiệm vụ ưu tiên cao', tasks.where((t) => (t['priority'] ?? '').toLowerCase() == 'cao' || (t['priority'] ?? '').toLowerCase() == 'high').length),
                  _statRow('Nhiệm vụ ưu tiên thấp', tasks.where((t) => (t['priority'] ?? '').toLowerCase() == 'thấp' || (t['priority'] ?? '').toLowerCase() == 'low').length),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tỉ lệ trạng thái nhiệm vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: completedTasks.toDouble(),
                    color: Colors.green,
                    title: 'Hoàn thành',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: overdueTasks.toDouble(),
                    color: Colors.red,
                    title: 'Trễ hạn',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: (totalTasks - completedTasks - overdueTasks).toDouble(),
                    color: Colors.orange,
                    title: 'Đang làm',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Số lượng nhân viên & nhiệm vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalUsers > totalTasks ? totalUsers : totalTasks).toDouble() + 5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Nhân viên');
                          case 1:
                            return const Text('Nhiệm vụ');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalUsers.toDouble(), color: Colors.blue, width: 32)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalTasks.toDouble(), color: Colors.orange, width: 32)]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Tỉ lệ nhân viên nghỉ phép', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: onLeaveUsers.toDouble(),
                    color: Colors.purple,
                    title: 'Nghỉ phép',
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: (totalUsers - onLeaveUsers).toDouble(),
                    color: Colors.blue,
                    title: 'Đi làm',
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }
}
