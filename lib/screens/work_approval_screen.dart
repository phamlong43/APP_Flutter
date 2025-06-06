import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/work_item.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class WorkApprovalScreen extends StatefulWidget {
  const WorkApprovalScreen({super.key});

  @override
  State<WorkApprovalScreen> createState() => _WorkApprovalScreenState();
}

class _WorkApprovalScreenState extends State<WorkApprovalScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<WorkItem> _pendingItems = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadPendingItems();
    _checkAdminPermissions();
  }

  // Kiểm tra xem người dùng hiện tại có phải là admin không
  Future<void> _checkAdminPermissions() async {
    try {
      // Sử dụng AuthService để kiểm tra quyền admin
      await AuthService.checkAdminAccess(context, 'admin');
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra quyền admin: $e');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _loadPendingItems() async {
    setState(() {
      _isLoading = true;
    });

    final pendingItemsData = await _dbHelper.getPendingWorkItems();
    final items =
        pendingItemsData.map((item) => WorkItem.fromMap(item)).toList();

    setState(() {
      _pendingItems = items;
      _isLoading = false;
    });
  }

  Future<void> _approveItem(WorkItem item) async {
    await _dbHelper.approveWorkItem(item.id!, 'Admin');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yêu cầu đã được phê duyệt')));
    _loadPendingItems();
  }

  Future<void> _rejectItem(WorkItem item) async {
    await _dbHelper.rejectWorkItem(item.id!, 'Admin');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yêu cầu đã bị từ chối')));
    _loadPendingItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phê duyệt công việc'),
        backgroundColor: Colors.blue,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingItems.isEmpty
              ? const Center(
                child: Text('Không có yêu cầu nào đang chờ phê duyệt'),
              )
              : ListView.builder(
                itemCount: _pendingItems.length,
                itemBuilder: (context, index) {
                  final item = _pendingItems[index];
                  return _buildWorkItemCard(item);
                },
              ),
    );
  }

  Widget _buildWorkItemCard(WorkItem item) {
    String typeLabel = '';
    Color typeColor = Colors.blue;

    // Xác định loại yêu cầu để hiển thị màu và nhãn tương ứng
    switch (item.type) {
      case 'leave':
        typeLabel = 'Nghỉ phép';
        typeColor = Colors.orange;
        break;
      case 'overtime':
        typeLabel = 'Tăng ca';
        typeColor = Colors.purple;
        break;
      case 'business_trip':
        typeLabel = 'Công tác';
        typeColor = Colors.green;
        break;
      case 'work_hours':
        typeLabel = 'Bổ sung công';
        typeColor = Colors.blue;
        break;
      default:
        typeLabel = item.type;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Người yêu cầu: ${item.userName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Ngày yêu cầu: ${item.requestedDate.split('T')[0]}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(item.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _rejectItem(item),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Từ chối',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _approveItem(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Phê duyệt',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
