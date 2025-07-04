import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_work_item_screen.dart';
import '../models/work_item.dart';

class UserWorkItemsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserWorkItemsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserWorkItemsScreen> createState() => _UserWorkItemsScreenState();
}

class _UserWorkItemsScreenState extends State<UserWorkItemsScreen> {
  List<WorkItem> _workItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkItems();
  }

  Future<void> _loadWorkItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/requests/my?username=${widget.userName}')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          final workItems = data.map<WorkItem>((item) => WorkItem(
            id: item['id'] ?? 0,
            title: item['title'] ?? '',
            description: item['description'] ?? '',
            status: item['status'] ?? '',
            requestedDate: item['createdAt'] ?? '',
            approvedDate: item['updatedAt'],
            approvedBy: '',
            type: item['requestType'] ?? '',
            userId: widget.userId,
            userName: widget.userName,
          )).toList();
          // Sắp xếp: các yêu cầu 'pending' lên đầu
          workItems.sort((a, b) {
            if (a.status == 'pending' && b.status != 'pending') return -1;
            if (a.status != 'pending' && b.status == 'pending') return 1;
            return 0;
          });
          setState(() {
            _workItems = workItems;
            _isLoading = false;
          });
        } else {
          setState(() {
            _workItems = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _workItems = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _workItems = [];
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Đang chờ';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu của tôi'),
        backgroundColor: Colors.blue,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _workItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có yêu cầu nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo yêu cầu mới bằng cách nhấn nút + phía dưới',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo yêu cầu mới'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CreateWorkItemScreen(
                                  userId: widget.userId,
                                  userName: widget.userName,
                                ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _loadWorkItems();
                          }
                        });
                      },
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadWorkItems,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _workItems.length,
                  itemBuilder: (context, index) {
                    final item = _workItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      item.status,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getStatusText(item.status),
                                    style: TextStyle(
                                      color: _getStatusColor(item.status),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ngày yêu cầu: ${item.requestedDate.split('T')[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (item.approvedDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Phản hồi bởi: ${item.approvedBy}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton:
          _workItems.isEmpty
              ? null
              : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CreateWorkItemScreen(
                            userId: widget.userId,
                            userName: widget.userName,
                          ),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _loadWorkItems();
                    }
                  });
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add),
              ),
    );
  }
}
