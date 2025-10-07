import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../task_list_screen.dart';
import '../request_list_screen.dart';
import '../../services/api_endpoints.dart';

class AdminStatCards extends StatefulWidget {
  final bool isLoadingUsers;
  final VoidCallback onUserTap;
  final VoidCallback onTaskTap;
  final VoidCallback onApprovalTap;

  const AdminStatCards({
    super.key,
    required this.isLoadingUsers,
    required this.onUserTap,
    required this.onTaskTap,
    required this.onApprovalTap,
  });

  @override
  State<AdminStatCards> createState() => _AdminStatCardsState();
}

class _AdminStatCardsState extends State<AdminStatCards> {
  int _pendingCount = 0;
  int _userCount = 0;
  int _taskCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingCount();
    _fetchUserCount();
    _fetchTaskCount();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // Cứ 5 giây tự động reload số lượng chờ duyệt, nhân sự và nhiệm vụ
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      await Future.wait([
        _fetchPendingCount(),
        _fetchUserCount(),
        _fetchTaskCount(),
      ]);
      return mounted;
    });
  }

  Future<void> _fetchPendingCount() async {
    setState(() { _loading = true; });
    try {
      // Lấy danh sách yêu cầu (requests) từ endpoint đúng
      final response = await http.get(Uri.parse(ApiEndpoints.allRequestsUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final pending = decoded.where((e) => (e['status'] ?? '').toLowerCase() == 'pending').toList();
          setState(() {
            _pendingCount = pending.length;
            _loading = false;
          });
        } else {
          setState(() { _loading = false; });
        }
      } else {
        setState(() { _loading = false; });
      }
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _fetchUserCount() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.usersUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final userCount = decoded.where((u) => (u is Map && (u['role'] != null && u['role'].toString().toUpperCase() == 'USER'))).length;
          if (mounted) setState(() { _userCount = userCount; });
        } else if (decoded is Map && decoded['users'] is List) {
          final userCount = (decoded['users'] as List).where((u) => (u is Map && (u['role'] != null && u['role'].toString().toUpperCase() == 'USER'))).length;
          if (mounted) setState(() { _userCount = userCount; });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchTaskCount() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.allTasksUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          if (mounted) setState(() { _taskCount = decoded.length; });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          Icons.groups, 'Nhân sự', Colors.blue, _userCount == 0 && _loading ? '...' : _userCount.toString(),
          onTap: widget.onUserTap,
        ),
        _buildStatCard(
          Icons.assignment_turned_in, 'Nhiệm vụ', Colors.orange, _taskCount == 0 ? '...' : _taskCount.toString(),
          onTap: widget.onTaskTap,
        ),
        _buildStatCard(
          Icons.approval, 'Yêu cầu', Colors.red, _loading ? '...' : _pendingCount.toString(),
          onTap: () async {
            // Lấy danh sách yêu cầu (requests) từ API và chuyển sang màn hình danh sách yêu cầu
            try {
              final response = await http.get(Uri.parse(ApiEndpoints.allRequestsUrl)).timeout(const Duration(seconds: 10));
              if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                if (decoded is List) {
                  if (context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestListScreen(
                          requests: List<Map<String, dynamic>>.from(decoded),
                        ),
                      ),
                    );
                    // Khi quay lại, cập nhật lại số lượng pending
                    if (mounted) _fetchPendingCount();
                  }
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể tải danh sách yêu cầu: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, Color color, String value, {VoidCallback? onTap, Key? key}) {
    return Expanded(
      key: key,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
