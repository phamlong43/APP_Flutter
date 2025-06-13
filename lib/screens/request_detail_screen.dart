import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool _actionTaken = false;

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
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

  IconData _statusIcon(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return Icons.timelapse;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final request = widget.request;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _statusColor(request['status']),
                      child: Icon(_statusIcon(request['status']), color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        request['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(),
                const SizedBox(height: 10),
                _infoRow('Loại yêu cầu', request['type'] ?? ''),
                _infoRow('Trạng thái', request['status'] ?? '', color: _statusColor(request['status'])),
                _infoRow('Ngày bắt đầu', request['startDate'] != null ? dateFormat.format(DateTime.parse(request['startDate'])) : ''),
                _infoRow('Ngày kết thúc', request['endDate'] != null ? dateFormat.format(DateTime.parse(request['endDate'])) : ''),
                _infoRow('Số ngày', request['days']?.toString() ?? ''),
                const SizedBox(height: 16),
                Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(request['description'] ?? '', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 16),
                Text('Lý do', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(request['reason'] ?? '', style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _actionTaken ? null : () async {
                        setState(() { _actionTaken = true; });
                        try {
                          final res = await http.put(
                            Uri.parse('http://10.0.2.2:8080/requests/${widget.request['id']}/approve'),
                          );
                          if (res.statusCode == 200) {
                            if (mounted) {
                              setState(() {
                                widget.request['status'] = 'approved';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt yêu cầu!')));
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi duyệt: \\${res.body}')));
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi duyệt: $e')));
                          }
                        }
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Duyệt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 18),
                    ElevatedButton.icon(
                      onPressed: _actionTaken ? null : () async {
                        setState(() { _actionTaken = true; });
                        try {
                          final res = await http.put(
                            Uri.parse('http://10.0.2.2:8080/requests/${widget.request['id']}/reject'),
                          );
                          if (res.statusCode == 200) {
                            if (mounted) {
                              setState(() {
                                widget.request['status'] = 'rejected';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối yêu cầu!')));
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi từ chối: \\${res.body}')));
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi từ chối: $e')));
                          }
                        }
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Từ chối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
