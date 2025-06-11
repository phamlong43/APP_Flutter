import 'package:flutter/material.dart';

import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const TaskListScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp: trạng thái (pending > completed > overdue), sau đó theo ngày hạn
    final sorted = [...tasks];
    sorted.sort((a, b) {
      int statusOrder(String s) {
        if (s == 'pending') return 0;
        if (s == 'completed') return 1;
        if (s == 'overdue') return 2;
        return 3;
      }
      final cmp = statusOrder(a['status'] ?? '').compareTo(statusOrder(b['status'] ?? ''));
      if (cmp != 0) return cmp;
      final da = DateTime.tryParse(a['dueDate'] ?? '') ?? DateTime(2100);
      final db = DateTime.tryParse(b['dueDate'] ?? '') ?? DateTime(2100);
      return da.compareTo(db);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhiệm vụ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemCount: sorted.length,
        itemBuilder: (ctx, i) {
          final t = sorted[i];
          Color statusColor;
          IconData statusIcon;
          String statusLabel = t['status'] ?? '';
          switch (statusLabel) {
            case 'completed':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              break;
            case 'overdue':
              statusColor = Colors.red;
              statusIcon = Icons.error;
              break;
            default:
              statusColor = Colors.orange;
              statusIcon = Icons.timelapse;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(task: t),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: statusColor.withOpacity(0.12),
                        child: Icon(statusIcon, color: statusColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['taskName'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 15, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(t['username'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 15, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('Hạn: ${t['dueDate'] ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.flag, size: 15, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('Trạng thái: ', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                Text(statusLabel, style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if ((t['description'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  t['description'],
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('#${t['id']}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(height: 10),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
