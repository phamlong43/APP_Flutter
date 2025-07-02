import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SalaryDetailScreen extends StatefulWidget {
  final int userId;

  const SalaryDetailScreen({super.key, this.userId = 2});

  @override
  State<SalaryDetailScreen> createState() => _SalaryDetailScreenState();
}

class _SalaryDetailScreenState extends State<SalaryDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _salaryData = {};
  List<dynamic> _attendanceData = [];
  double _totalWorkingHours = 0;
  double _hourlyWage = 0;
  final double _hourlyRate = 25000; // 25,000 VND per hour
  String _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _displayMonth = DateFormat('MM/yyyy').format(DateTime.now());
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Format currency values
  String _formatCurrency(dynamic value) {
    if (value == null) return '';
    
    final formatter = NumberFormat('#,###', 'vi_VN');
    if (value is String && value.isEmpty) return '';
    if (value is String) {
      try {
        return formatter.format(double.parse(value));
      } catch (e) {
        return value;
      }
    }
    return formatter.format(value);
  }

  // Function to fetch all required data
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get user data
      await _fetchUserData();
      
      // Get attendance data
      await _fetchAttendanceData();
      
      // Get salary data
      await _fetchSalaryData();
      
      // Calculate hourly wage
      _calculateHourlyWage();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  // Function to fetch user data
  Future<void> _fetchUserData() async {
    try {
      // List of endpoints to try
      final endpointsToTry = [
        'http://localhost:8080/users/id/${widget.userId}',
        'http://10.0.2.2:8080/users/id/${widget.userId}',
        'http://127.0.0.1:8080/users/id/${widget.userId}',
      ];

      for (String endpoint in endpointsToTry) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            setState(() {
              _userData = data;
            });
            print('User data loaded successfully');
            break;
          }
        } catch (e) {
          print('Failed with endpoint $endpoint: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Không thể lấy thông tin người dùng');
    }
  }

  // Function to fetch attendance data
  Future<void> _fetchAttendanceData() async {
    try {
      // Extract month and year for filtering attendance
      final yearMonth = _currentMonth.split('-');
      final year = yearMonth[0];
      final month = yearMonth[1];
      
      // List of endpoints to try
      final endpointsToTry = [
        'http://localhost:8080/api/attendance/user/${widget.userId}',
        'http://10.0.2.2:8080/api/attendance/user/${widget.userId}',
        'http://127.0.0.1:8080/api/attendance/user/${widget.userId}',
      ];

      for (String endpoint in endpointsToTry) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            if (data is List) {
              // Filter attendance records for the current month
              final filteredData = data.where((record) {
                if (record['workingDate'] != null) {
                  return record['workingDate'].toString().startsWith('$year-$month');
                }
                return false;
              }).toList();
              
              setState(() {
                _attendanceData = filteredData;
              });
              
              print('Attendance data loaded successfully: ${filteredData.length} records');
            }
            break;
          }
        } catch (e) {
          print('Failed with endpoint $endpoint: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }
  
  // Function to fetch salary data
  Future<void> _fetchSalaryData() async {
    try {
      // List of endpoints to try
      final endpointsToTry = [
        'http://localhost:8080/api/salaries/${widget.userId}?month=$_currentMonth',
        'http://10.0.2.2:8080/api/salaries/${widget.userId}?month=$_currentMonth',
        'http://127.0.0.1:8080/api/salaries/${widget.userId}?month=$_currentMonth',
        // Try without month parameter as fallback
        'http://localhost:8080/api/salaries/${widget.userId}',
        'http://10.0.2.2:8080/api/salaries/${widget.userId}',
        'http://127.0.0.1:8080/api/salaries/${widget.userId}',
      ];

      bool dataLoaded = false;
      
      for (String endpoint in endpointsToTry) {
        if (dataLoaded) break;
        
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            // If it's an array, take the first item
            final salaryData = data is List ? (data.isNotEmpty ? data[0] : {}) : data;
            
            setState(() {
              _salaryData = salaryData;
              
              // Update the display month if available in data
              if (salaryData.containsKey('monthYear') && salaryData['monthYear'] != null) {
                final monthYear = salaryData['monthYear'].toString();
                if (monthYear.length >= 7) { // format YYYY-MM
                  final dateComponents = monthYear.split('-');
                  if (dateComponents.length >= 2) {
                    _displayMonth = '${dateComponents[1]}/${dateComponents[0]}';
                  }
                }
              }
            });
            
            dataLoaded = true;
            print('Salary data loaded successfully');
            break;
          }
        } catch (e) {
          print('Failed with endpoint $endpoint: $e');
          continue;
        }
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('Error fetching salary data: $e');
      setState(() {
        _isLoading = false;
      });
      throw Exception('Không thể lấy thông tin lương');
    }
  }

  // Calculate total working hours and hourly wage
  void _calculateHourlyWage() {
    double totalHours = 0;
    
    for (var record in _attendanceData) {
      // If record has both checkIn and checkOut, calculate hours worked
      if (record['checkIn'] != null && record['checkOut'] != null) {
        try {
          final checkIn = DateTime.parse(record['checkIn']);
          final checkOut = DateTime.parse(record['checkOut']);
          
          // Calculate difference in hours
          final difference = checkOut.difference(checkIn).inMinutes / 60;
          totalHours += difference;
        } catch (e) {
          print('Error calculating hours for record: $e');
        }
      } 
      // If record has workingHours directly
      else if (record['workingHours'] != null) {
        try {
          totalHours += double.parse(record['workingHours'].toString());
        } catch (e) {
          print('Error parsing working hours: $e');
        }
      }
    }
    
    setState(() {
      _totalWorkingHours = double.parse(totalHours.toStringAsFixed(2));
      _hourlyWage = _totalWorkingHours * _hourlyRate;
    });
    
    print('Total working hours: $_totalWorkingHours');
    print('Hourly wage calculated: $_hourlyWage VND');
  }

  // Calculate the total income safely
  String _calculateTotalIncome() {
    try {
      double totalSalary = 0;
      if (_salaryData.containsKey('totalSalary') && _salaryData['totalSalary'] != null) {
        if (_salaryData['totalSalary'] is int) {
          totalSalary = _salaryData['totalSalary'].toDouble();
        } else if (_salaryData['totalSalary'] is double) {
          totalSalary = _salaryData['totalSalary'];
        } else {
          try {
            totalSalary = double.parse(_salaryData['totalSalary'].toString());
          } catch (e) {
            print('Error parsing totalSalary: $e');
          }
        }
      }
      
      final totalIncome = totalSalary + _hourlyWage;
      return _formatCurrency(totalIncome);
    } catch (e) {
      print('Error calculating total income: $e');
      return _formatCurrency(_hourlyWage); // Fallback to only hourly wage if error
    }
  }

  // Navigate to previous month
  void _previousMonth() {
    final currentDate = DateFormat('yyyy-MM').parse(_currentMonth);
    final previousMonth = DateTime(
      currentDate.year, 
      currentDate.month - 1, 
      1
    );
    
    setState(() {
      _currentMonth = DateFormat('yyyy-MM').format(previousMonth);
      _displayMonth = DateFormat('MM/yyyy').format(previousMonth);
    });
    
    _fetchData();
  }

  // Navigate to next month
  void _nextMonth() {
    final currentDate = DateFormat('yyyy-MM').parse(_currentMonth);
    final nextMonth = DateTime(
      currentDate.year, 
      currentDate.month + 1, 
      1
    );
    
    setState(() {
      _currentMonth = DateFormat('yyyy-MM').format(nextMonth);
      _displayMonth = DateFormat('MM/yyyy').format(nextMonth);
    });
    
    _fetchData();
  }

  // Build a simple calendar view of attendance
  Widget _buildAttendanceCalendar() {
    // Get days in the current month
    final yearMonth = _currentMonth.split('-');
    final year = int.parse(yearMonth[0]);
    final month = int.parse(yearMonth[1]);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    // Create a map of dates with attendance status
    Map<int, bool> attendanceDays = {};
    for (var record in _attendanceData) {
      if (record['workingDate'] != null) {
        try {
          final date = DateTime.parse(record['workingDate']);
          if (date.month == month && date.year == year) {
            attendanceDays[date.day] = true;
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Ngày làm việc trong tháng:', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(daysInMonth, (index) {
            final day = index + 1;
            final hasAttendance = attendanceDays[day] ?? false;
            
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasAttendance ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasAttendance ? Colors.green : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: hasAttendance ? Colors.green[800] : Colors.grey[600],
                    fontWeight: hasAttendance ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Lương Chi Tiết Nhân Viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 18),
                            onPressed: _previousMonth,
                          ),
                          Text(_displayMonth, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Summary card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tổng thu nhập: ${_calculateTotalIncome()} VND',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tổng giờ làm việc: $_totalWorkingHours giờ',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Số ngày làm việc: ${_attendanceData.length}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // User information section
                          _buildSectionTitle('Thông tin nhân viên'),
                          _buildRow('Mã nhân viên', _userData['employee_code']?.toString() ?? 'N/A'),
                          _buildRow('Họ tên', _userData['full_name']?.toString().isNotEmpty == true
                              ? _userData['full_name']
                              : _userData['username'] ?? 'N/A'),
                          _buildRow('Tên phòng ban', _userData['department']?.toString() ?? 'N/A'),
                          _buildRow('Vị trí', _userData['position']?.toString() ?? 'N/A'),
                          
                          const SizedBox(height: 16),
                          _buildSectionTitle('Thông tin lương'),
                          
                          // Salary information section
                          _buildRow('Lương cơ bản', _formatCurrency(_salaryData['basicSalary'])),
                          _buildRow('Phụ cấp', _formatCurrency(_salaryData['allowance'])),
                          _buildRow('Thưởng', _formatCurrency(_salaryData['bonus'])),
                          _buildRow('Khấu trừ', _formatCurrency(_salaryData['deduction'])),
                          _buildRow('Lương làm thêm giờ', _formatCurrency(_salaryData['overtimeSalary'])),
                          
                          // Hourly wage section
                          const SizedBox(height: 16),
                          _buildSectionTitle('Thông tin chấm công'),
                          _buildAttendanceCalendar(),
                          const SizedBox(height: 16),
                          
                          _buildSectionTitle('Lương theo giờ làm việc'),
                          _buildRow('Tổng số giờ làm việc', '$_totalWorkingHours giờ'),
                          _buildRow('Đơn giá mỗi giờ', _formatCurrency(_hourlyRate)),
                          _buildRow('Lương theo giờ', _formatCurrency(_hourlyWage)),
                          
                          const SizedBox(height: 16),
                          _buildSectionTitle('Tổng kết'),
                          _buildRow('Tổng lương', _calculateTotalIncome()),
                          _buildRow('Trạng thái', _formatStatus(_salaryData['status'])),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _formatStatus(String? status) {
    if (status == null) return 'N/A';
    
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
