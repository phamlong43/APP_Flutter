import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Hàm hiển thị tiêu đề cho biểu đồ cột
  static Widget getBottomTitles(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 1:
        text = 'Tháng 1';
        break;
      case 2:
        text = 'Tháng 2';
        break;
      case 3:
        text = 'Tháng 3';
        break;
      default:
        text = '';
    }
    return Text(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo & Thống Kê'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            const SizedBox(height: 20),
            _buildPieChartSection(),
            const SizedBox(height: 20),
            _buildBarChartSection(),
            const SizedBox(height: 20),
            _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatCard('Nhân viên', '123', Icons.people, Colors.blue),
        ),
        Expanded(
          child: _buildStatCard(
            'Ngày làm trung bình',
            '20',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'Đơn từ chờ duyệt',
            '5',
            Icons.assignment_late,
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'Tỷ lệ nghỉ',
            '3%',
            Icons.trending_down,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân bổ nhân viên theo phòng ban',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(value: 40, color: Colors.blue, title: 'IT'),
                PieChartSectionData(
                  value: 30,
                  color: Colors.orange,
                  title: 'HR',
                ),
                PieChartSectionData(
                  value: 20,
                  color: Colors.green,
                  title: 'Kế toán',
                ),
                PieChartSectionData(
                  value: 10,
                  color: Colors.red,
                  title: 'Khác',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số lượng đơn từ theo tháng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: 5, color: Colors.blue, width: 15),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(toY: 6, color: Colors.green, width: 15),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(toY: 3, color: Colors.orange, width: 15),
                  ],
                ),
              ],
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết nhân sự',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Tên')),
              DataColumn(label: Text('Phòng ban')),
              DataColumn(label: Text('Ngày vào')),
              DataColumn(label: Text('Trạng thái')),
            ],
            rows: const [
              DataRow(
                cells: [
                  DataCell(Text('Nguyễn Văn A')),
                  DataCell(Text('IT')),
                  DataCell(Text('01/01/2023')),
                  DataCell(Text('Đang làm')),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('Trần Thị B')),
                  DataCell(Text('HR')),
                  DataCell(Text('15/02/2023')),
                  DataCell(Text('Nghỉ việc')),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('Lê Văn C')),
                  DataCell(Text('Kế toán')),
                  DataCell(Text('20/03/2023')),
                  DataCell(Text('Đang làm')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
