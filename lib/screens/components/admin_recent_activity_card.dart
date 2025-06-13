import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AdminRecentActivityCard extends StatefulWidget {
  const AdminRecentActivityCard({super.key});

  @override
  State<AdminRecentActivityCard> createState() => _AdminRecentActivityCardState();
}

class _AdminRecentActivityCardState extends State<AdminRecentActivityCard> {
  List<Map<String, dynamic>> activities = [];
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchActivities();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchActivities());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchActivities() async {
    if (_loading) return;
    _loading = true;
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://10.0.2.2:8080/tasks/all')).timeout(const Duration(seconds: 10)),
        http.get(Uri.parse('http://10.0.2.2:8080/requests/all')).timeout(const Duration(seconds: 10)),
      ]);
      List<Map<String, dynamic>> newActivities = [];
      // Tasks
      if (responses[0].statusCode == 200) {
        final List<dynamic> tasks = json.decode(responses[0].body);
        for (var t in tasks) {
          newActivities.add({
            'type': t['status'] == 'completed' ? 'task_complete' : 'task',
            'title': t['status'] == 'completed'
                ? 'Nhiệm vụ "${t['taskName'] ?? ''}" đã hoàn thành'
                : 'Nhiệm vụ mới: "${t['taskName'] ?? ''}"',
            'createdAt': t['assignedAt'] ?? t['createdAt'] ?? t['updatedAt'],
          });
        }
      }
      // Requests
      if (responses[1].statusCode == 200) {
        final List<dynamic> requests = json.decode(responses[1].body);
        for (var r in requests) {
          newActivities.add({
            'type': r['status'] == 'approved' ? 'request_approved' : 'request',
            'title': r['status'] == 'approved'
                ? 'Yêu cầu "${r['title'] ?? ''}" đã được duyệt'
                : 'Yêu cầu mới: "${r['title'] ?? ''}"',
            'createdAt': r['createdAt'] ?? r['startDate'] ?? r['updatedAt'],
          });
        }
      }
      // Sắp xếp theo thời gian mới nhất
      newActivities.removeWhere((a) => a['createdAt'] == null);
      newActivities.sort((a, b) {
        final aTime = DateTime.tryParse(a['createdAt'].toString()) ?? DateTime(2000);
        final bTime = DateTime.tryParse(b['createdAt'].toString()) ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      // Lấy tối đa 3 sự kiện mới nhất
      newActivities = newActivities.take(3).toList();
      if (!listEquals(newActivities, activities)) {
        setState(() {
          activities = newActivities;
        });
      }
    } catch (e) {
      // ignore error
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FullActivityScreen(activities: activities),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hoạt động gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (activities.isEmpty)
                const Center(child: Text('Không có hoạt động gần đây'))
              else
                ...activities.map((activity) => ListTile(
                  leading: Icon(_getIcon(activity['type']), color: _getColor(activity['type'])),
                  title: Text(activity['title'] ?? ''),
                  subtitle: Text(_formatTime(activity['createdAt'])),
                )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'task_complete':
        return Icons.assignment_turned_in;
      case 'task':
        return Icons.assignment;
      case 'request_approved':
        return Icons.verified;
      case 'request':
        return Icons.assignment_late;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String? type) {
    switch (type) {
      case 'task_complete':
        return Colors.blue;
      case 'task':
        return Colors.green;
      case 'request_approved':
        return Colors.orange;
      case 'request':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(dynamic time) {
    if (time == null) return '';
    try {
      final dt = DateTime.parse(time.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return time.toString();
    }
  }
}

class _FullActivityScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  const _FullActivityScreen({Key? key, required this.activities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả hoạt động'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: activities.isEmpty
          ? const Center(child: Text('Không có hoạt động gần đây'))
          : ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  leading: Icon(_getIcon(activity['type']), color: _getColor(activity['type'])),
                  title: Text(activity['title'] ?? ''),
                  subtitle: Text(_formatTime(activity['createdAt'])),
                );
              },
            ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'task_complete':
        return Icons.assignment_turned_in;
      case 'task':
        return Icons.assignment;
      case 'request_approved':
        return Icons.verified;
      case 'request':
        return Icons.assignment_late;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String? type) {
    switch (type) {
      case 'task_complete':
        return Colors.blue;
      case 'task':
        return Colors.green;
      case 'request_approved':
        return Colors.orange;
      case 'request':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(dynamic time) {
    if (time == null) return '';
    try {
      final dt = DateTime.parse(time.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return time.toString();
    }
  }
}
