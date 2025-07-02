import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceCalendarScreen extends StatefulWidget {
  final String? userId; // Thêm parameter userId
  
  const AttendanceCalendarScreen({super.key, this.userId});

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _attendanceData = {}; // Thay đổi để lưu danh sách records cho mỗi ngày
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() { _loading = true; });
    
    try {
      // Sử dụng API endpoint mới theo yêu cầu
      final userId = widget.userId ?? '1'; // Sử dụng userId từ parameter hoặc mặc định là '1'
      final endpointsToTry = [
        'http://localhost:8080/api/attendance/user/$userId',
        'http://10.0.2.2:8080/api/attendance/user/$userId',
        'http://127.0.0.1:8080/api/attendance/user/$userId',
      ];

      bool success = false;
      
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Trying attendance endpoint: $endpoint');
          
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          print('DEBUG: Response status: ${response.statusCode}');
          print('DEBUG: Response body: ${response.body}');

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            
            // Chuyển đổi dữ liệu attendance thành format phù hợp cho calendar
            Map<String, List<Map<String, dynamic>>> attendanceMap = {};
            
            if (decoded is List) {
              // API trả về list các record attendance
              for (var record in decoded) {
                if (record['workingDate'] != null) {
                  final date = record['workingDate'] as String;
                  
                  // Xác định trạng thái dựa trên dữ liệu
                  String status = _determineStatus(record);
                  
                  // Format thời gian check-in/check-out để hiển thị
                  String checkInFormatted = '';
                  String checkOutFormatted = '';
                  
                  if (record['checkIn'] != null) {
                    try {
                      final checkInTime = DateTime.parse(record['checkIn']);
                      checkInFormatted = DateFormat('HH:mm').format(checkInTime);
                    } catch (e) {
                      checkInFormatted = record['checkIn'].toString();
                    }
                  }
                  
                  if (record['checkOut'] != null) {
                    try {
                      final checkOutTime = DateTime.parse(record['checkOut']);
                      checkOutFormatted = DateFormat('HH:mm').format(checkOutTime);
                    } catch (e) {
                      checkOutFormatted = record['checkOut'].toString();
                    }
                  }
                  
                  // Tạo object attendance record
                  final attendanceRecord = {
                    'status': status,
                    'checkIn': checkInFormatted,
                    'checkOut': checkOutFormatted,
                    'workingHours': record['workingHours'] ?? 0,
                    'overtimeHours': record['overtimeHours'] ?? 0,
                    'note': record['note'] ?? '',
                    'rawData': record, // Lưu dữ liệu gốc để debug
                  };
                  
                  // Thêm vào danh sách các record cho ngày này
                  if (attendanceMap[date] == null) {
                    attendanceMap[date] = [];
                  }
                  attendanceMap[date]!.add(attendanceRecord);
                }
              }
            } else if (decoded is Map) {
              // Nếu API trả về object đơn lẻ
              final record = decoded as Map<String, dynamic>;
              if (record['workingDate'] != null) {
                final date = record['workingDate'] as String;
                String status = _determineStatus(record);
                
                String checkInFormatted = '';
                String checkOutFormatted = '';
                
                if (record['checkIn'] != null) {
                  try {
                    final checkInTime = DateTime.parse(record['checkIn']);
                    checkInFormatted = DateFormat('HH:mm').format(checkInTime);
                  } catch (e) {
                    checkInFormatted = record['checkIn'].toString();
                  }
                }
                
                if (record['checkOut'] != null) {
                  try {
                    final checkOutTime = DateTime.parse(record['checkOut']);
                    checkOutFormatted = DateFormat('HH:mm').format(checkOutTime);
                  } catch (e) {
                    checkOutFormatted = record['checkOut'].toString();
                  }
                }
                
                final attendanceRecord = {
                  'status': status,
                  'checkIn': checkInFormatted,
                  'checkOut': checkOutFormatted,
                  'workingHours': record['workingHours'] ?? 0,
                  'overtimeHours': record['overtimeHours'] ?? 0,
                  'note': record['note'] ?? '',
                  'rawData': record,
                };
                
                // Thêm vào danh sách các record cho ngày này
                if (attendanceMap[date] == null) {
                  attendanceMap[date] = [];
                }
                attendanceMap[date]!.add(attendanceRecord);
              }
            }
            
            setState(() { 
              _attendanceData = attendanceMap;
            });
            success = true;
            print('DEBUG: Successfully loaded ${attendanceMap.length} attendance records');
            break;
          }
        } catch (e) {
          print('DEBUG: Endpoint $endpoint failed: $e');
          continue;
        }
      }
      
      if (!success) {
        print('DEBUG: All endpoints failed, using empty data');
        setState(() { _attendanceData = {}; });
      }
      
    } catch (e) {
      print('DEBUG: General error: $e');
      setState(() { _attendanceData = {}; });
    }
    
    setState(() { _loading = false; });
  }

  // Helper function để xác định trạng thái chấm công
  String _determineStatus(Map<String, dynamic> record) {
    final checkIn = record['checkIn'];
    final checkOut = record['checkOut'];
    final status = record['status']?.toString().toLowerCase();
    
    // Kiểm tra các trạng thái đặc biệt từ API
    if (status == 'leave' || status == 'nghỉ phép') {
      return 'Nghỉ phép có lương';
    }
    if (status == 'unpaid_leave' || status == 'nghỉ không lương') {
      return 'Nghỉ không lương';
    }
    if (status == 'business_trip' || status == 'công tác') {
      return 'Công tác';
    }
    if (status == 'completed') {
      return 'Chấm công đúng giờ';
    }
    
    // Kiểm tra trạng thái chấm công dựa trên checkIn/checkOut
    if (checkIn != null && checkOut != null) {
      return 'Chấm công đúng giờ';
    }
    if (checkIn != null && checkOut == null) {
      return 'Quên checkout';
    }
    if (checkIn == null) {
      return 'Không chấm công';
    }
    
    return 'Không chấm công';
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
      final attendanceList = _attendanceData[key];
      
      Color color;
      String status = '';
      
      // Xử lý trường hợp có nhiều lần chấm công trong ngày
      if (attendanceList != null && attendanceList.isNotEmpty) {
        // Lấy trạng thái từ record cuối cùng hoặc tổng hợp
        if (attendanceList.length == 1) {
          status = attendanceList[0]['status'] as String;
        } else {
          status = '${attendanceList.length} lần';
        }
      }
      
      if (status == 'Nghỉ phép có lương') color = Colors.blue;
      else if (status == 'Nghỉ không lương') color = Colors.purple;
      else if (status == 'Công tác') color = Colors.orange;
      else if (status == 'Chấm công đúng giờ') color = Colors.green;
      else if (status == 'Quên checkin/checkout') color = Colors.red;
      else if (status == 'Quên checkout') color = Colors.red;
      else if (status == 'Không chấm công') color = Colors.grey;
      else if (status.contains('lần')) color = Colors.purple; // Nhiều lần chấm công
      else color = Colors.grey.shade300;
      dayWidgets.add(GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(
                'Chi tiết ngày $i/${_selectedMonth.month}/${_selectedMonth.year}',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5, // Giới hạn chiều cao
                child: attendanceList == null || attendanceList.isEmpty
                  ? const Text('Không có dữ liệu chấm công') 
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hiển thị thông tin tổng quát
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                attendanceList.length == 1 
                                  ? 'Trạng thái: ${attendanceList[0]['status']}' 
                                  : 'Số lần chấm công: ${attendanceList.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Hiển thị từng lần chấm công
                            ...attendanceList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final att = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lần ${index + 1}: ${att['status']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    if ((att['checkIn'] ?? '').toString().isNotEmpty) 
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          'Giờ vào: ${att['checkIn']}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    if ((att['checkOut'] ?? '').toString().isNotEmpty) 
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          'Giờ ra: ${att['checkOut']}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      )
                                    else if ((att['checkIn'] ?? '').toString().isNotEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          'Giờ ra: Chưa check-out', 
                                          style: TextStyle(color: Colors.red, fontSize: 13),
                                        ),
                                      ),
                                    if ((att['workingHours'] ?? 0) > 0) 
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          'Giờ làm việc: ${att['workingHours']} giờ',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    if ((att['overtimeHours'] ?? 0) > 0) 
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          'Giờ tăng ca: ${att['overtimeHours']} giờ',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    if ((att['note'] ?? '').toString().isNotEmpty) 
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          'Ghi chú: ${att['note']}',
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
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
                Flexible(
                  child: Text(
                    status, 
                    style: TextStyle(fontSize: 10, color: color),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
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
    int present = 0;
    int leave = 0;
    int absent = 0;
    int late = 0;
    int business = 0;
    
    // Duyệt qua tất cả các ngày và tính toán thống kê
    for (var dayRecords in _attendanceData.values) {
      if (dayRecords.isNotEmpty) {
        // Lấy trạng thái chính của ngày (có thể từ record cuối cùng hoặc logic tổng hợp)
        var primaryRecord = dayRecords.last;
        String status = primaryRecord['status'] ?? '';
        
        switch (status) {
          case 'Chấm công đúng giờ':
            present++;
            break;
          case 'Nghỉ phép có lương':
            leave++;
            break;
          case 'Không chấm công':
            absent++;
            break;
          case 'Quên checkout':
          case 'Quên checkin/checkout':
            late++;
            break;
          case 'Công tác':
            business++;
            break;
        }
      } else {
        absent++; // Ngày không có dữ liệu = vắng mặt
      }
    }
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
            _summaryItem('Quên out', late),
            _summaryItem('Vắng mặt', absent),
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
        LegendDot(label: 'Quên checkout', color: Colors.red),
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
