import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class WorkScheduleScreen extends StatefulWidget {
  final int employeeId;
  final int createdBy;
  // Có thể thêm các trường user khác nếu cần

  const WorkScheduleScreen({
    super.key,
    required this.employeeId,
    required this.createdBy,
  });

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map ngày -> danh sách ca làm việc (List<Map<String, dynamic>>)
  final Map<DateTime, List<Map<String, dynamic>>> _workData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    fetchAllWorkSchedules();
  }

  List<Map<String, dynamic>> getWorkForDay(DateTime day) {
    return _workData[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> fetchAllWorkSchedules() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/workschedules?employeeId=${widget.employeeId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          _workData.clear();
          for (final item in data) {
            if (item is Map<String, dynamic> && item['workDate'] != null) {
              final workDate = DateTime.tryParse(item['workDate']);
              if (workDate != null) {
                final key = DateTime(workDate.year, workDate.month, workDate.day);
                _workData.putIfAbsent(key, () => []);
                _workData[key]!.add({
                  'shift': item['shift'] ?? 'Tùy chỉnh',
                  'status': item['status'] ?? item['notes'] ?? '',
                  'notes': item['notes'] ?? '',
                  'startTime': item['startTime'],
                  'endTime': item['endTime'],
                  'color': Colors.blue,
                });
              }
            }
          }
          setState(() {});
        }
      }
    } catch (e) {
      // Lỗi kết nối, không cập nhật gì
    }
  }

  @override
  Widget build(BuildContext context) {
    final works = _selectedDay != null ? getWorkForDay(_selectedDay!) : [];
    // Sắp xếp theo startTime nếu có nhiều lịch trong ngày
    works.sort((a, b) {
      final aTime = DateTime.tryParse(a['startTime'] ?? '') ?? DateTime(2000);
      final bTime = DateTime.tryParse(b['startTime'] ?? '') ?? DateTime(2000);
      return aTime.compareTo(bTime);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Làm Việc'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: ListView(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            const SizedBox(height: 16),
            if (_selectedDay != null && works.isNotEmpty)
              ...works.map((work) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: work['color'] as Color),
                  title: Text('${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (work['startTime'] != null && work['endTime'] != null)
                        Text('Giờ: '
                          '${DateTime.tryParse(work['startTime']) != null ? TimeOfDay.fromDateTime(DateTime.parse(work['startTime'])).format(context) : ''} - '
                          '${DateTime.tryParse(work['endTime']) != null ? TimeOfDay.fromDateTime(DateTime.parse(work['endTime'])).format(context) : ''}'),
                      if ((work['notes'] ?? '').toString().isNotEmpty)
                        Text('Ghi chú: ${work['notes']}'),
                    ],
                  ),
                  tileColor: (work['color'] as Color? ?? Colors.blue).withOpacity(0.1),
                ),
              )).toList()
            else if (_selectedDay != null)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Không có ca làm việc cho ngày này.'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedDay == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hãy chọn ngày trên lịch!')));
            return;
          }
          final TextEditingController notesController = TextEditingController();
          TimeOfDay? startTime;
          TimeOfDay? endTime;
          await showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return AlertDialog(
                    title: const Text('Tạo lịch làm việc'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ngày: \\${_selectedDay!.day}/\\${_selectedDay!.month}/\\${_selectedDay!.year}'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(labelText: 'Ghi chú'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final picked = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay(hour: 8, minute: 0));
                                      if (picked != null) {
                                        setStateDialog(() {
                                          startTime = picked;
                                        });
                                      }
                                    },
                                    child: const Text('Chọn giờ bắt đầu'),
                                  ),
                                  if (startTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('Đã chọn: \\${startTime!.format(context)}', style: const TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final picked = await showTimePicker(context: context, initialTime: endTime ?? TimeOfDay(hour: 17, minute: 0));
                                      if (picked != null) {
                                        setStateDialog(() {
                                          endTime = picked;
                                        });
                                      }
                                    },
                                    child: const Text('Chọn giờ kết thúc'),
                                  ),
                                  if (endTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('Đã chọn: \\${endTime!.format(context)}', style: const TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (startTime == null || endTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chọn giờ bắt đầu/kết thúc!')));
                            return;
                          }
                          // Chuẩn bị dữ liệu mẫu
                          final now = DateTime.now();
                          final workDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, startTime!.hour, startTime!.minute);
                          final endDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, endTime!.hour, endTime!.minute);
                          final data = {
                            "employeeId": widget.employeeId,
                            "createdBy": widget.createdBy,
                            "workDate": workDate.toIso8601String(),
                            "startTime": workDate.toIso8601String(),
                            "endTime": endDate.toIso8601String(),
                            "notes": notesController.text,
                            "createdAt": now.toIso8601String(),
                            "updatedAt": now.toIso8601String(),
                          };
                          // Gửi API tạo lịch làm việc
                          final url = Uri.parse('http://10.0.2.2:8080/api/workschedules');
                          try {
                            final response = await http.post(
                              url,
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode(data),
                            );
                            if (response.statusCode == 200 || response.statusCode == 201) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo lịch thành công!')));
                              await fetchAllWorkSchedules();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tạo lịch thất bại: \\${response.statusCode}')));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối API!')));
                          }
                        },
                        child: const Text('Tạo'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo lịch làm việc',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
