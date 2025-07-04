import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';

class CheckInOutButton extends StatefulWidget {
  final String userId;
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final Function(bool isCheckedIn, DateTime? checkInTime) onStatusChanged;

  const CheckInOutButton({
    super.key,
    required this.userId,
    required this.isCheckedIn,
    required this.checkInTime,
    required this.onStatusChanged,
  });

  @override
  State<CheckInOutButton> createState() => _CheckInOutButtonState();
}

class _CheckInOutButtonState extends State<CheckInOutButton> {
  bool _isLoading = false;

  // Helper function để format thời gian hiển thị
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper function để tính toán thời gian làm việc
  String _calculateWorkingHours() {
    return AttendanceService.calculateWorkingHours(widget.checkInTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isCheckedIn ? Colors.red : Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: _isLoading 
          ? null 
          : () async {
              if (widget.isCheckedIn) {
                await _handleCheckOut();
              } else {
                await _handleCheckIn();
              }
            },
        child: _isLoading 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)
            ) 
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isCheckedIn ? Icons.logout : Icons.access_time,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isCheckedIn ? 'Kết thúc Ca' : 'Vào Ca',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    // Hiển thị dialog xác nhận vào ca
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.green),
            SizedBox(width: 8),
            Text('Xác nhận vào ca'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thời gian: ${_formatTime(DateTime.now())}'),
            const SizedBox(height: 8),
            Text('Ngày: ${DateTime.now().toIso8601String().substring(0, 10)}'),
            const SizedBox(height: 8),
            const Text('Bạn có chắc muốn vào ca không?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Vào Ca', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Nếu user xác nhận, thực hiện check-in
    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      
      final result = await AttendanceService.performCheckIn(widget.userId);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success'] == true) {
        widget.onStatusChanged(true, result['checkInTime']);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['message']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['error']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleCheckOut() async {
    // Hiển thị dialog xác nhận kết thúc ca
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận kết thúc ca'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thời gian kết thúc: ${_formatTime(DateTime.now())}'),
            const SizedBox(height: 8),
            Text('Ngày: ${DateTime.now().toIso8601String().substring(0, 10)}'),
            const SizedBox(height: 8),
            if (widget.checkInTime != null) ...[
              Text('Thời gian vào ca: ${_formatTime(widget.checkInTime!)}'),
              const SizedBox(height: 8),
              Text('Tổng thời gian làm việc: ${_calculateWorkingHours()} giờ'),
              const SizedBox(height: 8),
            ],
            const Text('Bạn có chắc muốn kết thúc ca không?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Kết thúc Ca', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Nếu user xác nhận, thực hiện check-out
    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      
      final result = await AttendanceService.performCheckOut(widget.userId, widget.checkInTime);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success'] == true) {
        widget.onStatusChanged(false, null);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['message']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['error']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}
