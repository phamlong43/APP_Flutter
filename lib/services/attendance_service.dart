import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceService {
  // API endpoints
  static const List<String> _endpointsToTry = [
    'http://10.0.2.2:8080/api/attendance',
    'http://10.0.2.2:8080/attendance',
    'http://localhost:8080/api/attendance',
    'http://localhost:8080/attendance',
    'http://127.0.0.1:8080/api/attendance',
  ];

  // Function để kiểm tra trạng thái chấm công hiện tại từ API
  static Future<Map<String, dynamic>> checkCurrentAttendanceStatus(String userId) async {
    try {
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      
      debugPrint('DEBUG: Checking current attendance status for date: $workingDate');

      // Thử từng endpoint để lấy dữ liệu
      for (String endpoint in _endpointsToTry) {
        try {
          String getUrl = '$endpoint?userId=$userId&date=$workingDate';
          final response = await http.get(
            Uri.parse(getUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            debugPrint('DEBUG: Current attendance data: ${jsonEncode(data)}');
            
            if (data is List && data.isNotEmpty) {
              // Tìm record hôm nay có status = pending (đang trong ca)
              final todayRecords = data.where(
                (record) => record['workingDate'] == workingDate
              ).toList();
              
              debugPrint('DEBUG: Today records count: ${todayRecords.length}');
              
              final activeRecord = todayRecords.firstWhere(
                (record) => record['status'] == 'pending',
                orElse: () => null,
              );
              
              if (activeRecord != null) {
                // Có bản ghi pending, đang trong ca làm việc
                return {
                  'isCheckedIn': true,
                  'checkInTime': DateTime.tryParse(activeRecord['createdAt'] ?? ''),
                  'attendanceRecord': activeRecord,
                  'todayRecords': todayRecords
                };
              } else {
                // Không có bản ghi pending
                return {
                  'isCheckedIn': false,
                  'checkInTime': null,
                  'todayRecords': todayRecords
                };
              }
            }
            
            // Không có dữ liệu chấm công hôm nay
            return {
              'isCheckedIn': false,
              'checkInTime': null,
              'todayRecords': []
            };
          }
        } catch (e) {
          debugPrint('DEBUG: Failed to check attendance status with endpoint $endpoint: $e');
          continue;
        }
      }
      
      // Không kết nối được với bất kỳ endpoint nào
      return {
        'isCheckedIn': false,
        'checkInTime': null,
        'error': 'Không thể kết nối tới server'
      };
    } catch (e) {
      debugPrint('DEBUG: General error checking attendance status: $e');
      return {
        'isCheckedIn': false,
        'checkInTime': null,
        'error': e.toString()
      };
    }
  }

  // Function để thực hiện check-in (vào ca)
  static Future<Map<String, dynamic>> performCheckIn(String userId) async {
    try {
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      
      // Tạo data theo format yêu cầu đơn giản - luôn POST mới với status = pending
      final createData = {
        "user": {
          "id": int.tryParse(userId) ?? 1
        },
        "workingDate": workingDate,
        "status": "pending"
      };

      debugPrint('DEBUG: Check-in data: ${jsonEncode(createData)}');

      // Sử dụng endpoint chính theo yêu cầu
      const String endpoint = 'http://localhost:8080/api/attendance';

      try {
        debugPrint('DEBUG: Creating new attendance record at: $endpoint');
        
        // POST mới record với status = pending
        final postResponse = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(createData),
        ).timeout(const Duration(seconds: 10));
        
        debugPrint('DEBUG: Check-in POST response: ${postResponse.statusCode}');
        
        if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
          return {
            'success': true,
            'isCheckedIn': true,
            'checkInTime': now,
            'message': 'Vào ca thành công lúc ${_formatTime(now)}'
          };
        } else {
          String errorMsg = 'POST Status ${postResponse.statusCode}: ${postResponse.body}';
          return {
            'success': false,
            'error': errorMsg
          };
        }
      } catch (e) {
        debugPrint('DEBUG: Check-in failed: $e');
        return {
          'success': false,
          'error': 'Lỗi vào ca: $e'
        };
      }
    } catch (e) {
      debugPrint('DEBUG: Check-in general exception: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e'
      };
    }
  }

  // Function để thực hiện check-out (kết thúc ca)
  static Future<Map<String, dynamic>> performCheckOut(String userId, DateTime? checkInTime) async {
    try {
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      
      // Tạo data theo format yêu cầu - chỉ cập nhật status = out
      final updateData = {
        "status": "out"
      };

      debugPrint('DEBUG: Check-out data: ${jsonEncode(updateData)}');

      // Sử dụng endpoint chính theo yêu cầu
      const String endpoint = 'http://localhost:8080/api/attendance';
      
      try {
        debugPrint('DEBUG: Performing check-out with endpoint: $endpoint');
        
        // Bước 1: Tìm record hôm nay với status = pending
        String getUrl = '$endpoint?userId=$userId&date=$workingDate';
        final getResponse = await http.get(
          Uri.parse(getUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (getResponse.statusCode == 200) {
          final data = jsonDecode(getResponse.body);
          
          if (data is List && data.isNotEmpty) {
            // Tìm record hôm nay có status = pending (đang trong ca)
            final todayRecord = data.firstWhere(
              (record) => record['workingDate'] == workingDate && record['status'] == "pending",
              orElse: () => null,
            );
            
            if (todayRecord != null && todayRecord['id'] != null) {
              // Bước 2: Chỉ cập nhật status = out, không thay đổi bất kỳ trường nào khác
              final putResponse = await http.put(
                Uri.parse('$endpoint/${todayRecord['id']}'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(updateData),
              ).timeout(const Duration(seconds: 10));

              debugPrint('DEBUG: Check-out PUT response status: ${putResponse.statusCode}');
              debugPrint('DEBUG: Check-out PUT response body: ${putResponse.body}');

              if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
                // Tính thời gian làm việc nếu có thông tin check-in
                double workingHours = 8.0; // Mặc định 8 giờ
                if (checkInTime != null) {
                  final duration = now.difference(checkInTime);
                  workingHours = duration.inMinutes / 60.0;
                  workingHours = double.parse(workingHours.toStringAsFixed(2));
                }
                
                return {
                  'success': true,
                  'isCheckedIn': false,
                  'workingHours': workingHours,
                  'message': 'Kết thúc ca thành công! Thời gian làm việc: $workingHours giờ'
                };
              } else {
                return {
                  'success': false,
                  'error': 'PUT Status ${putResponse.statusCode}: ${putResponse.body}'
                };
              }
            } else {
              return {
                'success': false,
                'error': 'Không tìm thấy record với status = pending'
              };
            }
          } else {
            return {
              'success': false,
              'error': 'Không có dữ liệu chấm công'
            };
          }
        } else {
          return {
            'success': false,
            'error': 'GET Status ${getResponse.statusCode}: ${getResponse.body}'
          };
        }
      } catch (e) {
        debugPrint('DEBUG: Check-out failed: $e');
        return {
          'success': false,
          'error': 'Lỗi kết thúc ca: $e'
        };
      }
    } catch (e) {
      debugPrint('DEBUG: Check-out general exception: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: $e'
      };
    }
  }

  // Helper function để format thời gian hiển thị
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper function để tính toán thời gian làm việc
  static String calculateWorkingHours(DateTime? checkInTime) {
    if (checkInTime == null) return '0.00';
    
    final now = DateTime.now();
    final duration = now.difference(checkInTime);
    final hours = duration.inMinutes / 60.0;
    return hours.toStringAsFixed(2);
  }
}
