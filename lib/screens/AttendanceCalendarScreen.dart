import 'package:flutter/material.dart';

class AttendanceCalendarScreen extends StatelessWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Công Cá Nhân Chi Tiết'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {},
                ),
                const Text(
                  '05/2021',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Image.asset('assets/calendar_mockup.png'),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    LegendDot(label: 'Nghỉ phép có lương', color: Colors.blue),
                    LegendDot(label: 'Nghỉ không lương', color: Colors.purple),
                    LegendDot(label: 'Công tác', color: Colors.orange),
                    LegendDot(label: 'Chấm công đúng giờ', color: Colors.green),
                    LegendDot(label: 'Quên checkin/checkout', color: Colors.red),
                    LegendDot(label: 'Không chấm công', color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSummaryTile(),
                const Divider(height: 30),
                ..._buildAttendanceDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _summaryCard('23.5', 'Công chuẩn'),
        _summaryCard('0.5', 'Nghỉ có lương'),
        _summaryCard('0.0', 'Nghỉ không lương'),
        _summaryCard('1', 'Quên in/out'),
        _summaryCard('31', 'Số ngày'),
        _summaryCard('14.94', 'Công đã làm'),
        _summaryCard('0.50', 'Nghỉ lễ'),
        _summaryCard('15.44', 'Tổng công'),
      ],
    );
  }

  List<Widget> _buildAttendanceDetails() {
    return [
      _attendanceEntry(
        date: '03/05/2021',
        checkIn: '08:15',
        checkOut: '17:37',
        late: '15.00',
        early: '0.00',
        workedHours: '7.75',
        employeeName: 'Nguyễn Chí Thanh',
        position: 'Marketing - Ca hành chính',
      ),
      _attendanceEntry(
        date: '04/05/2021',
        checkIn: '08:00',
        checkOut: '17:50',
        late: '0.00',
        early: '0.00',
        workedHours: '8.00',
        employeeName: 'Nguyễn Chí Thanh',
        position: 'Marketing - Ca hành chính',
      ),
    ];
  }

  Widget _attendanceEntry({
    required String date,
    required String checkIn,
    required String checkOut,
    required String late,
    required String early,
    required String workedHours,
    required String employeeName,
    required String position,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$employeeName - Ngày làm : $date',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(position),
          const Text('Loại chấm công:'),
          Text('Giờ vào: $checkIn  -  Giờ ra: $checkOut'),
          Text('Số giờ: $workedHours'),
          Text('Đi trễ: $late phút  -  Về sớm: $early phút'),
          const Divider(),
        ],
      ),
    );
  }

  Widget _summaryCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
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
