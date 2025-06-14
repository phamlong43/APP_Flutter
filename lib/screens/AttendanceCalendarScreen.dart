import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<String, Map<String, dynamic>> _attendanceData = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() { _loading = true; });
    final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
    try {
      // Thay endpoint phù hợp với backend của bạn
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/attendance?month=$monthStr'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          // Chuyển đổi đúng kiểu Map<String, Map<String, dynamic>>
          final Map<String, Map<String, dynamic>> parsed = decoded.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
          setState(() { _attendanceData = parsed; });
        }
      }
    } catch (_) {}
    setState(() { _loading = false; });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
    _fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final weekdayOffset = firstDay.weekday % 7;
    final List<Widget> dayWidgets = [];
    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(const SizedBox());
    }
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, i);
      final key = DateFormat('yyyy-MM-dd').format(date);
      final att = _attendanceData[key];
      Color color;
      String status = att?['status'] ?? '';
      if (status == 'Nghỉ phép có lương') color = Colors.blue;
      else if (status == 'Nghỉ không lương') color = Colors.purple;
      else if (status == 'Công tác') color = Colors.orange;
      else if (status == 'Chấm công đúng giờ') color = Colors.green;
      else if (status == 'Quên checkin/checkout') color = Colors.red;
      else if (status == 'Không chấm công') color = Colors.grey;
      else color = Colors.grey.shade300;
      dayWidgets.add(GestureDetector(
        onTap: att == null ? null : () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Chi tiết ngày $i/${_selectedMonth.month}/${_selectedMonth.year}'),
              content: att == null ? const Text('Không có dữ liệu') : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trạng thái: $status'),
                  if ((att['checkIn'] ?? '').toString().isNotEmpty) Text('Giờ vào: ${att['checkIn']}'),
                  if ((att['checkOut'] ?? '').toString().isNotEmpty) Text('Giờ ra: ${att['checkOut']}'),
                  if ((att['note'] ?? '').toString().isNotEmpty) Text('Ghi chú: ${att['note']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$i', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                Text(status, style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng công nhân viên'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Center(child: Text(DateFormat('MM/yyyy').format(_selectedMonth), style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('CN', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('T2'),
                      Text('T3'),
                      Text('T4'),
                      Text('T5'),
                      Text('T6'),
                      Text('T7'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 7,
                      children: dayWidgets,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummary(),
                  const SizedBox(height: 12),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary() {
    int total = _attendanceData.length;
    int present = _attendanceData.values.where((e) => e['status'] == 'Chấm công đúng giờ').length;
    int leave = _attendanceData.values.where((e) => e['status'] == 'Nghỉ phép có lương').length;
    int absent = _attendanceData.values.where((e) => e['status'] == 'Không chấm công').length;
    int late = _attendanceData.values.where((e) => e['status'] == 'Quên checkin/checkout').length;
    int business = _attendanceData.values.where((e) => e['status'] == 'Công tác').length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem('Tổng ngày', total),
            _summaryItem('Đi làm', present),
            _summaryItem('Nghỉ phép', leave),
            _summaryItem('Công tác', business),
            _summaryItem('Quên in/out', late),
            _summaryItem('Không công', absent),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, int value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: const [
        LegendDot(label: 'Nghỉ phép có lương', color: Colors.blue),
        LegendDot(label: 'Nghỉ không lương', color: Colors.purple),
        LegendDot(label: 'Công tác', color: Colors.orange),
        LegendDot(label: 'Chấm công đúng giờ', color: Colors.green),
        LegendDot(label: 'Quên checkin/checkout', color: Colors.red),
        LegendDot(label: 'Không chấm công', color: Colors.grey),
      ],
    );
  }
}

class LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const LegendDot({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
