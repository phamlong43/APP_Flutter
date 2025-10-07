import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/api_endpoints.dart';

class RewardDisciplineScreen extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final String username;

  const RewardDisciplineScreen({
    super.key, 
    this.isAdmin = false, 
    this.userId = '1',
    this.username = 'User',
  });

  @override
  State<RewardDisciplineScreen> createState() => _RewardDisciplineScreenState();
}

class _RewardDisciplineScreenState extends State<RewardDisciplineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _rewardsList = [];
  List<Map<String, dynamic>> _disciplinesList = [];
  
  // Controllers for form fields
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'reward';
  String _selectedEmployee = '1';
  List<Map<String, dynamic>> _employees = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRewardsAndDisciplines();
    if (widget.isAdmin) {
      _fetchEmployees();
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _reasonController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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
  
  // Format date values
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // Fetch employees for admin
  Future<void> _fetchEmployees() async {
    try {
      final endpointsToTry = [
        'http://localhost:8080/users',
        ApiEndpoints.usersUrl,
      ];
      
      bool success = false;
      
      for (String endpoint in endpointsToTry) {
        try {
          print('Fetching employees from $endpoint');
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));
          
          print('Response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            print('Fetched ${data.length} employees');
            
            // Filter only user role employees (optional)
            final filteredData = data.where((user) => 
                (user['role'] == null) || 
                user['role'].toString().toUpperCase() == 'USER'
            ).toList();
            
            setState(() {
              _employees = filteredData.map((e) => {
                'id': e['id'].toString(),
                'name': e['full_name'] != null && e['full_name'].toString().isNotEmpty 
                    ? e['full_name'] 
                    : (e['username'] ?? 'User ${e['id']}'),
              }).toList();
              
              // Make sure there's at least one item
              if (_employees.isEmpty) {
                _employees.add({
                  'id': widget.userId,
                  'name': widget.username,
                });
              }
              
              // Set default selected employee
              _selectedEmployee = _employees.first['id'].toString();
            });
            
            success = true;
            break;
          }
        } catch (e) {
          print('Failed to fetch employees from $endpoint: $e');
          continue;
        }
      }
      
      if (!success) {
        // Add current user as fallback if we couldn't get the list
        setState(() {
          _employees = [{
            'id': widget.userId,
            'name': widget.username,
          }];
          _selectedEmployee = widget.userId;
        });
        
        print('Using fallback employee list with current user');
      }
    } catch (e) {
      print('Error fetching employees: $e');
      
      // Add current user as fallback
      setState(() {
        _employees = [{
          'id': widget.userId,
          'name': widget.username,
        }];
        _selectedEmployee = widget.userId;
      });
    }
  }
  
  // Fetch rewards and disciplines
  Future<void> _fetchRewardsAndDisciplines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Determine endpoint based on role
      String endpointSuffix = widget.isAdmin 
          ? '' 
          : '/employee/${widget.userId}';
          
      final endpointsToTry = [
        'http://localhost:8080/api/reward-discipline$endpointSuffix',
        ApiEndpoints.getRewardDisciplineWithFilterUrl(endpointSuffix),
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
            final List<dynamic> data = jsonDecode(response.body);
            
            final rewards = data.where((item) => item['type'] == 'reward').toList();
            final disciplines = data.where((item) => item['type'] == 'discipline').toList();
            
            setState(() {
              _rewardsList = List<Map<String, dynamic>>.from(rewards);
              _disciplinesList = List<Map<String, dynamic>>.from(disciplines);
              _isLoading = false;
            });
            
            break;
          }
        } catch (e) {
          print('Failed to fetch data from $endpoint: $e');
          continue;
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể kết nối tới máy chủ: $e';
      });
      print('Error fetching data: $e');
    }
  }
  
  // Create new reward or discipline
  Future<void> _createRewardDiscipline() async {
    if (_titleController.text.isEmpty || 
        _reasonController.text.isEmpty ||
        _selectedEmployee.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Handle amount parsing safely
      int amount = 0;
      if (_amountController.text.isNotEmpty) {
        try {
          // Remove all non-digit characters and parse
          final cleanedAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanedAmount.isNotEmpty) {
            amount = int.parse(cleanedAmount);
          }
        } catch (e) {
          print('Error parsing amount: $e');
        }
      }
      
      // Capture the selected employee ID to ensure it's not changed during the request
      final selectedEmployeeId = _selectedEmployee;
      
      final data = {
        "employeeId": int.parse(selectedEmployeeId),
        "type": _selectedType,
        "title": _titleController.text,
        "reason": _reasonController.text,
        "amount": amount,
        "effectiveDate": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "notes": _notesController.text,
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String()
      };
      
      final endpointsToTry = [
        'http://localhost:8080/api/reward-discipline',
        ApiEndpoints.rewardDisciplineUrl,
      ];
      
      bool success = false;
      
      // Log the data for debugging
      print('Sending data to API: ${jsonEncode(data)}');
      print('Selected employee ID: $_selectedEmployee');
      print('employeeId being sent: ${data["employeeId"]}');
      
      String errorMessage = '';
      for (String endpoint in endpointsToTry) {
        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          ).timeout(const Duration(seconds: 15));
          
          print('Response from $endpoint: ${response.statusCode}');
          print('Response body: ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            success = true;
            break;
          } else {
            // Store the error message
            errorMessage = 'Mã lỗi: ${response.statusCode}, Chi tiết: ${response.body}';
          }
        } catch (e) {
          print('Failed to post to $endpoint: $e');
          errorMessage = e.toString();
          continue;
        }
      }
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (success) {
        // Clear form fields
        _titleController.clear();
        _reasonController.clear();
        _amountController.clear();
        _notesController.clear();
        _selectedDate = DateTime.now();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedType == 'reward' 
                ? 'Khen thưởng đã được tạo thành công' 
                : 'Kỷ luật đã được tạo thành công'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh data
        _fetchRewardsAndDisciplines();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.isNotEmpty 
                  ? 'Không thể tạo mới: $errorMessage' 
                  : 'Không thể tạo mới. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khen thưởng & Kỷ luật'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Khen thưởng'),
            Tab(text: 'Kỷ luật'),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchRewardsAndDisciplines,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRewardsTab(),
                    _buildDisciplineTab(),
                  ],
                ),
      floatingActionButton: widget.isAdmin 
          ? FloatingActionButton(
              onPressed: () => _showCreateForm(context),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            ) 
          : null,
    );
  }
  
  void _showCreateForm(BuildContext context) {
    // Set the type based on current tab
    _selectedType = _tabController.index == 0 ? 'reward' : 'discipline';
    
    // Reset form fields
    _titleController.clear();
    _reasonController.clear();
    _amountController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();
    
    // Reset the selected employee value
    setState(() {
      // Set default employee - if employees list is empty, use default ID 1
      if (_employees.isNotEmpty) {
        _selectedEmployee = _employees.first['id'].toString();
      } else {
        _selectedEmployee = widget.userId; // Default to current user if no list
      }
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedType == 'reward' 
                      ? 'Tạo khen thưởng mới' 
                      : 'Tạo kỷ luật mới',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Employee dropdown
                StatefulBuilder(
                  builder: (context, setModalState) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Nhân viên',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: _selectedEmployee,
                      items: _employees.isEmpty 
                          ? [
                              DropdownMenuItem<String>(
                                value: "1",
                                child: Text("Chưa tải được danh sách nhân viên"),
                              )
                            ]
                          : _employees.map<DropdownMenuItem<String>>((employee) {
                              return DropdownMenuItem<String>(
                                value: employee['id'].toString(),
                                child: Text(employee['name'].toString()),
                              );
                            }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          // Update both in the modal state and the parent state
                          setModalState(() {
                            _selectedEmployee = value;
                          });
                          setState(() {
                            _selectedEmployee = value;
                          });
                          print('Employee selection changed to: $value');
                        }
                      },
                    );
                  }
                ),
                const SizedBox(height: 16),
                
                // Title field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _selectedType == 'reward' 
                        ? 'Tiêu đề khen thưởng' 
                        : 'Tiêu đề kỷ luật',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Amount field (for rewards or penalties)
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: _selectedType == 'reward' 
                        ? 'Số tiền thưởng (VNĐ)'
                        : 'Số tiền phạt (VNĐ)',
                    border: const OutlineInputBorder(),
                    hintText: '0',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    helperText: 'Nhập số không có dấu phẩy hoặc chấm',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Format the display value as user types
                    if (value.isNotEmpty) {
                      try {
                        // Only keep digits
                        final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanValue.isNotEmpty) {
                          final number = int.parse(cleanValue);
                          
                          // Format with thousands separators for display
                          final formatter = NumberFormat('#,###', 'vi_VN');
                          final formattedText = formatter.format(number);
                          
                          if (formattedText != value) {
                            // Update text field with formatted value
                            _amountController.value = TextEditingValue(
                              text: formattedText,
                              selection: TextSelection.collapsed(offset: formattedText.length),
                            );
                          }
                        }
                      } catch (e) {
                        print('Error formatting amount: $e');
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Reason field
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: _selectedType == 'reward' 
                        ? 'Lý do khen thưởng' 
                        : 'Lý do kỷ luật',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Date picker
                ListTile(
                  title: const Text('Ngày hiệu lực:'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Notes field
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _createRewardDiscipline();
                    },
                    child: Text(
                      _selectedType == 'reward' 
                          ? 'Tạo khen thưởng' 
                          : 'Tạo kỷ luật',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRewardsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return _rewardsList.isEmpty
        ? const Center(child: Text('Chưa có thông tin khen thưởng'))
        : RefreshIndicator(
            onRefresh: _fetchRewardsAndDisciplines,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _rewardsList.length,
              itemBuilder: (context, index) {
                final reward = _rewardsList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reward['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Ngày khen thưởng:', _formatDate(reward['effectiveDate'])),
                        _buildInfoRow('Số tiền:', '${_formatCurrency(reward['amount'])} VNĐ'),
                        _buildInfoRow('Lý do:', reward['reason'] ?? ''),
                        if (reward['notes'] != null && reward['notes'].toString().isNotEmpty)
                          _buildInfoRow('Ghi chú:', reward['notes']),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
  
  Widget _buildDisciplineTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return _disciplinesList.isEmpty
        ? const Center(child: Text('Chưa có thông tin kỷ luật'))
        : RefreshIndicator(
            onRefresh: _fetchRewardsAndDisciplines,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _disciplinesList.length,
              itemBuilder: (context, index) {
                final discipline = _disciplinesList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                discipline['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Ngày kỷ luật:', _formatDate(discipline['effectiveDate'])),
                        _buildInfoRow('Lý do:', discipline['reason'] ?? ''),
                        if (discipline['amount'] != null && discipline['amount'] > 0)
                          _buildInfoRow('Số tiền phạt:', '${_formatCurrency(discipline['amount'])} VNĐ'),
                        if (discipline['notes'] != null && discipline['notes'].toString().isNotEmpty)
                          _buildInfoRow('Ghi chú:', discipline['notes']),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
