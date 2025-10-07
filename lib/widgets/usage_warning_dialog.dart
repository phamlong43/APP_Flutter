import 'package:flutter/material.dart';
import '../services/app_usage_tracker_new.dart';

class UsageWarningDialog extends StatelessWidget {
  final int usageMinutes;
  final bool isLimit;

  const UsageWarningDialog({
    Key? key,
    required this.usageMinutes,
    this.isLimit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            isLimit ? Icons.warning : Icons.access_time,
            color: isLimit ? Colors.red : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            isLimit ? 'Giới hạn sử dụng!' : 'Cảnh báo thời gian!',
            style: TextStyle(
              color: isLimit ? Colors.red : Colors.orange[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLimit ? Colors.red[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLimit ? Colors.red[200]! : Colors.orange[200]!,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Bạn đã sử dụng ứng dụng:',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '$usageMinutes phút (${(usageMinutes / 60).toStringAsFixed(1)} giờ)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLimit ? Colors.red : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            isLimit 
              ? '🚨 Bạn đã vượt quá giới hạn 120 phút (2 giờ) sử dụng trong ngày!'
              : '⚠️ Bạn sắp đạt giới hạn 120 phút sử dụng trong ngày.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Gợi ý cho sức khỏe:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Nghỉ ngơi 5-10 phút', style: TextStyle(fontSize: 12)),
                    Text('• Nhìn xa để thư giãn mắt', style: TextStyle(fontSize: 12)),
                    Text('• Uống nước và vận động nhẹ', style: TextStyle(fontSize: 12)),
                    Text('• Quay lại làm việc sau', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đã hiểu'),
        ),
        if (!isLimit)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showUsageStats(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Xem thống kê'),
          ),
        if (isLimit)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Tạm dừng'),
          ),
      ],
    );
  }

  void _showUsageStats(BuildContext context) {
    final stats = AppUsageTracker.instance.getUsageStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue),
            SizedBox(width: 8),
            Text('Thống kê sử dụng hôm nay'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Thời gian đã dùng', '${stats['currentMinutes']} phút'),
            _buildStatRow('Thời gian còn lại', '${stats['remainingMinutes']} phút'),
            _buildStatRow('Trạng thái', stats['isOverLimit'] ? 'Vượt giới hạn' : 'Bình thường'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (stats['currentMinutes'] as int) / AppUsageTracker.LIMIT_MINUTES,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                (stats['isOverLimit'] as bool) ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiến độ: ${((stats['currentMinutes'] as int) / AppUsageTracker.LIMIT_MINUTES * 100).round()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function để hiển thị cảnh báo sử dụng
void showUsageWarning(BuildContext context, int minutes, {bool isLimit = false}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => UsageWarningDialog(
      usageMinutes: minutes,
      isLimit: isLimit,
    ),
  );
}

class OldUsageWarningDialog {
  /// Hiển thị dialog cảnh báo sử dụng quá lâu
  static void show(BuildContext context) {
  final stats = AppUsageTracker.instance.getUsageStats();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Cảnh báo thời gian sử dụng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Bạn đã sử dụng ứng dụng quá lâu!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⏰ Thời gian hôm nay: '
                    '${(((stats['currentMinutes'] ?? 0) as int) / 60).toStringAsFixed(1)} giờ',
                  ),
                  Text('📝 Giới hạn khuyến nghị: ${AppUsageTracker.WARNING_MINUTES ~/ 60} giờ'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: const Text(
                      'Sử dụng thiết bị quá lâu có thể gây hại cho sức khỏe mắt và tư thế.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '💡 Khuyến nghị:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Nghỉ ngơi 15-20 phút'),
            const Text('• Nhìn xa để thư giãn mắt'),
            const Text('• Vận động cơ thể nhẹ nhàng'),
            const Text('• Uống nước và thở sâu'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tiếp tục sử dụng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Có thể thêm logic pause app ở đây
              _showBreakReminder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Nghỉ ngơi ngay'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị lời nhắc nghỉ ngơi
  static void _showBreakReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.spa, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Thời gian nghỉ ngơi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.self_improvement, size: 64, color: Colors.green[600]),
            const SizedBox(height: 16),
            const Text(
              'Hãy dành 15-20 phút để nghỉ ngơi.\nẢnh hưởng tích cực đến sức khỏe!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('🧘 Thư giãn mắt: Nhìn xa 20 giây'),
                  Text('🚶 Đi bộ nhẹ quanh phòng'),
                  Text('💧 Uống một ly nước'),
                  Text('🫁 Thở sâu 5-10 lần'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị thống kê sử dụng ứng dụng
class UsageStatsWidget extends StatefulWidget {
  const UsageStatsWidget({Key? key}) : super(key: key);

  @override
  State<UsageStatsWidget> createState() => _UsageStatsWidgetState();
}

class _UsageStatsWidgetState extends State<UsageStatsWidget> {
  Map<String, dynamic> _usage = {};

  @override
  void initState() {
    super.initState();
    _updateUsage();
  }

  void _updateUsage() {
    setState(() {
  _usage = AppUsageTracker.instance.getUsageStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Thống kê sử dụng hôm nay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Thời gian sử dụng
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_usage['isOverLimit'] ?? false) 
                  ? Colors.red[50] 
                  : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_usage['isOverLimit'] ?? false) 
                    ? Colors.red[200]! 
                    : Colors.blue[200]!,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${((_usage['currentMinutes'] ?? 0) / 60).toStringAsFixed(1)} giờ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: (_usage['isOverLimit'] ?? false) 
                        ? Colors.red[700] 
                        : Colors.blue[700],
                    ),
                  ),
                  Text(
                    '${_usage['currentMinutes'] ?? 0} phút',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar
            LinearProgressIndicator(
              value: (_usage['currentMinutes'] ?? 0) / AppUsageTracker.WARNING_MINUTES,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                (_usage['isOverLimit'] ?? false) 
                  ? Colors.red 
                  : Colors.blue,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Thông tin thêm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Giới hạn: ${AppUsageTracker.WARNING_MINUTES} phút',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  (_usage['isOverLimit'] ?? false)
                    ? 'Vượt ${((_usage['currentMinutes'] ?? 0) - AppUsageTracker.WARNING_MINUTES).abs()} phút'
                    : 'Còn ${_usage['remainingMinutes'] ?? 0} phút',
                  style: TextStyle(
                    fontSize: 12,
                    color: (_usage['isOverLimit'] ?? false) 
                      ? Colors.red 
                      : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _updateUsage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cập nhật'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Thêm 30 phút test
                      AppUsageTracker.instance.addTestMinutes(30);
                      _updateUsage();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Test +30p'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
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
