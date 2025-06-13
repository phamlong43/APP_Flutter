import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<String, Map<String, dynamic>> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  void _loadDemoData() {
    // Dữ liệu mẫu: key là yyyy-MM-dd, value là trạng thái và ghi chú
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final Map<String, Map<String, dynamic>> data = {};
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      final key = DateFormat('yyyy-MM-dd').format(date);
      data[key] = {
        'status': i % 7 == 0 ? 'Nghỉ' : (i % 6 == 0 ? 'Đi muộn' : 'Đi làm'),
        'note': i % 6 == 0 ? 'Đến muộn 15 phút' : '',
        'checkIn': i % 7 == 0 ? null : '08:00',
        'checkOut': i % 7 == 0 ? null : '17:00',
      };
    }
    setState(() {
      _attendanceData = data;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
      // Nếu dùng API, gọi API lấy dữ liệu tháng mới ở đây
      _loadDemoData();
    });
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
      if (status == 'Nghỉ') color = Colors.grey;
      else if (status == 'Đi muộn') color = Colors.orange;
      else color = Colors.green;
      dayWidgets.add(GestureDetector(
        onTap: att == null ? null : () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Chi tiết ngày $i/${_selectedMonth.month}/${_selectedMonth.year}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trạng thái: $status'),
                  if ((att['checkIn'] ?? '').isNotEmpty) Text('Giờ vào: ${att['checkIn']}'),
                  if ((att['checkOut'] ?? '').isNotEmpty) Text('Giờ ra: ${att['checkOut']}'),
                  if ((att['note'] ?? '').isNotEmpty) Text('Ghi chú: ${att['note']}'),
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
      body: Padding(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    int total = _attendanceData.length;
    int work = _attendanceData.values.where((e) => e['status'] == 'Đi làm').length;
    int late = _attendanceData.values.where((e) => e['status'] == 'Đi muộn').length;
    int off = _attendanceData.values.where((e) => e['status'] == 'Nghỉ').length;
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Tổng: $total ngày'),
            Text('Đi làm: $work'),
            Text('Đi muộn: $late'),
            Text('Nghỉ: $off'),
          ],
        ),
      ),
    );
  }
}
