import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'request_detail_screen.dart';

class RequestListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> requests;
  const RequestListScreen({super.key, required this.requests});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = false;
  bool _firstLoad = true;
  @override
  void initState() {
    super.initState();
    _requests = List<Map<String, dynamic>>.from(widget.requests);
    _loading = true;
    _firstLoad = false;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      await _fetchRequests();
      return mounted;
    });
  }

  Future<void> _fetchRequests() async {
    // Không setState({ _loading = true }) khi auto-refresh, chỉ khi lần đầu
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/requests/all')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final newRequests = List<Map<String, dynamic>>.from(decoded);
          final isChanged = _requests.length != newRequests.length || !_listEquals(_requests, newRequests);
          if (isChanged) {
            setState(() {
              _requests = newRequests;
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

  @override
  Widget build(BuildContext context) {
    final sorted = [..._requests];
    sorted.sort((a, b) {
      int statusOrder(String s) {
        if (s == 'pending') return 0;
        if (s == 'completed') return 1;
        if (s == 'overdue') return 2;
        return 3;
      }
      final cmp = statusOrder(a['status'] ?? '').compareTo(statusOrder(b['status'] ?? ''));
      if (cmp != 0) return cmp;
      final da = DateTime.tryParse(a['endDate'] ?? '') ?? DateTime(2100);
      final db = DateTime.tryParse(b['endDate'] ?? '') ?? DateTime(2100);
      return da.compareTo(db);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách yêu cầu'),
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
            switch (statusLabel) {
              case 'completed':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'overdue':
                statusColor = Colors.red;
                statusIcon = Icons.error;
                break;
              case 'pending':
                statusColor = Colors.orange;
                statusIcon = Icons.timelapse;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.help;
            }
            return InkWell(
              onTap: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => RequestDetailScreen(request: t),
                  ),
                );
              },
              child: Card(
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
                              t['title'] ?? '',
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
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text('Từ: ${t['startDate'] ?? ''}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 16),
                          Text('Đến: ${t['endDate'] ?? ''}', style: const TextStyle(fontSize: 14)),
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
                      if ((t['reason'] ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Lý do: ${t['reason']}', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                        ),
                      const SizedBox(height: 10),
                      if ((statusLabel.trim().toLowerCase() == 'pending'))
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final res = await http.put(Uri.parse('http://10.0.2.2:8080/requests/${t['id']}/approve'));
                                  if (res.statusCode == 200) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Đã duyệt yêu cầu!')));
                                    }
                                  } else {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Lỗi duyệt: \\${res.body}')));
                                    }
                                  }
                                } catch (e) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Lỗi duyệt: $e')));
                                  }
                                }
                              },
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('Accept'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final res = await http.put(Uri.parse('http://10.0.2.2:8080/requests/${t['id']}/reject'));
                                  if (res.statusCode == 200) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Đã từ chối yêu cầu!')));
                                    }
                                  } else {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Lỗi từ chối: \\${res.body}')));
                                    }
                                  }
                                } catch (e) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Lỗi từ chối: $e')));
                                  }
                                }
                              },
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}
