import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LichSuChamCongScreen extends StatefulWidget {
  final String? userId;
  final String? role; // Role của người dùng (ADMIN, USER, ...)
  
  const LichSuChamCongScreen({super.key, this.userId, this.role});

  @override
  State<LichSuChamCongScreen> createState() => _LichSuChamCongScreenState();
}

class _LichSuChamCongScreenState extends State<LichSuChamCongScreen> {
  List<Map<String, dynamic>> attendanceLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceLogs();
  }

  Future<void> _fetchAttendanceLogs() async {
    setState(() => isLoading = true);
    
    try {
      // Danh sách endpoints để thử
      final endpointsToTry = [
        'http://10.0.2.2:8080/api/attendance',
        'http://10.0.2.2:8080/attendance',
        'http://localhost:8080/api/attendance',
        'http://localhost:8080/attendance',
        'http://127.0.0.1:8080/api/attendance',
      ];

      bool success = false;
      
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Trying to fetch attendance from: $endpoint');
          
          // Nếu có userId, thêm vào query parameters
          String url = endpoint;
          if (widget.userId != null) {
            url += '?userId=${widget.userId}';
          }
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          print('DEBUG: Attendance response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            setState(() {
              if (data is List) {
                attendanceLogs = List<Map<String, dynamic>>.from(data);
                // Cập nhật sample data nếu không có username (cho trường hợp không có API)
                for (var log in attendanceLogs) {
                  if (log['user'] == null) {
                    log['user'] = {'username': 'user${log['id'] ?? ''}'}; 
                  }
                }
              } else if (data is Map && data['attendance'] is List) {
                attendanceLogs = List<Map<String, dynamic>>.from(data['attendance']);
              }
              success = true;
              print('DEBUG: Fetched ${attendanceLogs.length} records with user data structure: ${attendanceLogs.isNotEmpty ? attendanceLogs[0].containsKey('user') : 'empty'}');
            });
            break;
          }
        } catch (e) {
          print('DEBUG: Failed to fetch from $endpoint: $e');
          continue;
        }
      }

      // Nếu không thể kết nối API, sử dụng dữ liệu mẫu
      if (!success) {
        setState(() {
          attendanceLogs = [
            {
              'id': 1,
              'user': {
                'id': 2,
                'username': 'user1',
                'role': 'USER'
              },
              'workingDate': '2025-06-30',
              'checkIn': '2025-06-30T08:00:00',
              'checkOut': '2025-06-30T17:00:00',
              'workingHours': 8,
              'overtimeHours': 0,
              'status': 'completed'
            },
            {
              'id': 2,
              'user': {
                'id': 3,
                'username': 'user2',
                'role': 'USER'
              },
              'workingDate': '2025-06-29',
              'checkIn': '2025-06-29T08:15:00',
              'checkOut': '2025-06-29T17:10:00',
              'workingHours': 8,
              'overtimeHours': 1,
              'status': 'completed'
            },
            {
              'id': 3,
              'user': {
                'id': 2,
                'username': 'user1',
                'role': 'USER'
              },
              'workingDate': '2025-06-28',
              'checkIn': '2025-06-28T08:05:00',
              'checkOut': '2025-06-28T17:05:00',
              'workingHours': 8,
              'overtimeHours': 0,
              'status': 'completed'
            },
            {
              'id': 4,
              'user': {
                'id': 4,
                'username': 'user3',
                'role': 'USER'
              },
              'workingDate': '2025-06-27',
              'checkIn': '2025-06-27T08:20:00',
              'checkOut': null,
              'workingHours': 0,
              'overtimeHours': 0,
              'status': 'pending'
            },
          ];
        });
      }
    } catch (e) {
      print('DEBUG: General error fetching attendance: $e');
      // Fallback to sample data
      setState(() {
        attendanceLogs = [
          {
            'id': 1,
            'user': {
              'id': 1,
              'username': 'fallback_user',
              'role': 'USER'
            },
            'workingDate': '2025-06-30',
            'checkIn': '2025-06-30T08:00:00',
            'checkOut': '2025-06-30T17:00:00',
            'workingHours': 8,
            'overtimeHours': 0,
            'status': 'completed'
          },
        ];
      });
    }
    
    setState(() => isLoading = false);
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--:--';
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '--/--/----';
    try {
      final dateTime = DateTime.parse(isoDate);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return '--/--/----';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Widget helper để xây dựng dòng thông tin thống nhất
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500, 
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14, 
              color: valueColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Chấm Công'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAttendanceLogs,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceLogs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có lịch sử chấm công',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAttendanceLogs,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: attendanceLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log = attendanceLogs[index];
                      final status = log['status'] ?? 'unknown';
                      final isCompleted = status.toLowerCase() == 'completed';
                      
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header với ngày và status
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: _getStatusColor(status).withOpacity(0.2),
                                    child: Icon(
                                      isCompleted ? Icons.check_circle : Icons.access_time,
                                      color: _getStatusColor(status),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ngày: ${_formatDate(log['workingDate'])}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: _getStatusColor(status),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Username (người chấm công) - Chỉ hiển thị cho admin
                              if (widget.role?.toUpperCase() == 'ADMIN') ...[
                                _buildInfoRow(
                                  icon: Icons.person,
                                  iconColor: Colors.purple,
                                  label: 'Người dùng:',
                                  value: log['user'] != null ? log['user']['username'] ?? 'Không có thông tin' : 'Không có thông tin',
                                ),
                                const SizedBox(height: 8),
                              ],
                              
                              // Thời gian vào
                              _buildInfoRow(
                                icon: Icons.login,
                                iconColor: Colors.green,
                                label: 'Giờ vào:',
                                value: _formatTime(log['checkIn']),
                              ),
                              const SizedBox(height: 8),
                              
                              // Thời gian ra
                              _buildInfoRow(
                                icon: Icons.logout,
                                iconColor: Colors.red,
                                label: 'Giờ ra:',
                                value: _formatTime(log['checkOut']),
                              ),
                              const SizedBox(height: 8),
                              
                              // Giờ làm việc
                              _buildInfoRow(
                                icon: Icons.work_outline,
                                iconColor: Colors.blue,
                                label: 'Giờ làm:',
                                value: '${log['workingHours'] ?? 0} giờ',
                              ),
                              
                              // Tăng ca (chỉ hiển thị nếu có)
                              if ((log['overtimeHours'] ?? 0) > 0) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  icon: Icons.access_time_filled,
                                  iconColor: Colors.orange,
                                  label: 'Tăng ca:',
                                  value: '${log['overtimeHours']} giờ',
                                  valueColor: Colors.orange,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
