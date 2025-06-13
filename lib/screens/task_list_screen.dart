import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final String? title;
  const TaskListScreen({super.key, required this.tasks, this.title});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _tasks = List<Map<String, dynamic>>.from(widget.tasks);
    _loading = true;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      await _fetchTasks();
      return mounted;
    });
  }

  Future<void> _fetchTasks() async {
    // Không setState({ _loading = true }) khi auto-refresh, chỉ khi lần đầu
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/tasks/all')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final newTasks = List<Map<String, dynamic>>.from(decoded);
          final isChanged = _tasks.length != newTasks.length || !_listEquals(_tasks, newTasks);
          if (isChanged) {
            setState(() {
              _tasks = newTasks;
              _loading = false;
            });
          } else if (_loading) {
            setState(() { _loading = false; });
          }
        } else if (_loading) {
          setState(() { _loading = false; });
        }
      } else if (_loading) {
        setState(() { _loading = false; });
      }
    } catch (e) {
      if (_loading) {
        setState(() { _loading = false; });
      }
    }
  }

  bool _listEquals(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_mapEquals(a[i], b[i])) return false;
    }
    return true;
  }

  bool _mapEquals(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  String _formatDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(value.toString());
      if (dt == null) return value.toString();
      // Định dạng dd/MM/yyyy HH:mm
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._tasks];
    sorted.sort((a, b) {
      final da = DateTime.tryParse(a['dueDate'] ?? '') ?? DateTime(2100);
      final db = DateTime.tryParse(b['dueDate'] ?? '') ?? DateTime(2100);
      return da.compareTo(db);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Danh sách nhiệm vụ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: sorted.length,
          itemBuilder: (ctx, i) {
            final t = sorted[i];
            Color statusColor;
            IconData statusIcon;
            String statusLabel = t['status'] ?? '';
            switch (statusLabel.toLowerCase()) {
              case 'completed':
              case 'hoàn thành':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'overdue':
              case 'không hoàn thành':
                statusColor = Colors.red;
                statusIcon = Icons.error;
                break;
              case 'pending':
              case 'đang chạy':
                statusColor = Colors.orange;
                statusIcon = Icons.timelapse;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.help;
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t['taskName'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cập nhật: ' + _formatDateTime(t['assignedAt']),
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 22),
                        Expanded(
                          child: Text(
                            'Hạn: ${t['dueDate'] ?? ''}',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if ((t['description'] ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          t['description'],
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    if ((t['username'] ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Người nhận: ${t['username']}', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                      ),
                    // Thêm 2 nút cập nhật trạng thái nếu chưa hoàn thành/thất bại
                    if ((statusLabel.toLowerCase() != 'completed' && statusLabel.toLowerCase() != 'hoàn thành' && statusLabel.toLowerCase() != 'failed' && statusLabel.toLowerCase() != 'overdue' && statusLabel.toLowerCase() != 'không hoàn thành'))
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check, color: Colors.white),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _updateTaskStatus(t['id'], 'completed', t['username']),
                                label: const Text('Đã hoàn thành'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => _updateTaskStatus(t['id'], 'failed', t['username']),
                                label: const Text('Thất bại'),
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
    );
  }

// Thêm hàm cập nhật trạng thái nhiệm vụ
  Future<void> _updateTaskStatus(dynamic taskId, String status, String username) async {
    setState(() { _loading = true; });
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/tasks/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'taskId': taskId,
          'status': status,
          'username': username,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        await _fetchTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật trạng thái thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật trạng thái: ${response.body}')),
        );
        setState(() { _loading = false; });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
      setState(() { _loading = false; });
    }
  }
}
