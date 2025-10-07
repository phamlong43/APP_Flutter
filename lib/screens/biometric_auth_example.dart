import 'package:flutter/material.dart';
import '../utils/biometric_auth_helper.dart';

class BiometricAuthExample extends StatefulWidget {
  const BiometricAuthExample({Key? key}) : super(key: key);

  @override
  State<BiometricAuthExample> createState() => _BiometricAuthExampleState();
}

class _BiometricAuthExampleState extends State<BiometricAuthExample> {
  bool _isAvailable = false;
  Map<String, dynamic>? _deviceCapabilities;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await BiometricAuthHelper.isAvailable();
    final capabilities = await BiometricAuthHelper.getDeviceCapabilities();
    
    setState(() {
      _isAvailable = available;
      _deviceCapabilities = capabilities;
    });
  }

  /// Hàm xác thực chính - tương tự như code Android native bạn đã cung cấp
  Future<void> _authenticateUser() async {
    // Tương đương với việc tạo BiometricPrompt trong Android
    final result = await BiometricAuthHelper.authenticate(
      context: context,
      title: 'Xác thực sinh trắc học',
      subtitle: 'Dùng vân tay hoặc khuôn mặt để xác nhận danh tính',
      cancelText: 'Huỷ',
    );

    if (result) {
      // Tương đương với onAuthenticationSucceeded
      _onAuthenticationSucceeded();
    } else {
      // Tương đương với onAuthenticationFailed
      _onAuthenticationFailed();
    }
  }

  /// Callback khi xác thực thành công
  void _onAuthenticationSucceeded() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Xác thực thành công!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
    
    // TODO: Cho phép truy cập tính năng (ví dụ: điểm danh, mở cửa, đăng nhập...)
    _navigateToSecureFeature();
  }

  /// Callback khi xác thực thất bại
  void _onAuthenticationFailed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('Xác thực thất bại!'),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Điều hướng đến tính năng bảo mật sau khi xác thực thành công
  void _navigateToSecureFeature() {
    // Ví dụ: điều hướng đến màn hình chấm công, thông tin cá nhân...
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.green),
            SizedBox(width: 8),
            Text('Truy cập được cấp phép'),
          ],
        ),
        content: const Text(
          'Bạn đã xác thực thành công!\n'
          'Có thể truy cập vào các tính năng bảo mật như:\n'
          '• Chấm công\n'
          '• Thông tin cá nhân\n'
          '• Tài liệu nhạy cảm\n'
          '• Đăng nhập hệ thống',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực sinh trắc học'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card hiển thị trạng thái thiết bị
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAvailable ? Icons.check_circle : Icons.error,
                          color: _isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trạng thái thiết bị',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isAvailable 
                        ? '✅ Thiết bị hỗ trợ xác thực sinh trắc học'
                        : '❌ Thiết bị chưa sẵn sàng cho xác thực sinh trắc học',
                    ),
                    if (_deviceCapabilities != null) ...[
                      const SizedBox(height: 8),
                      Text('Hỗ trợ thiết bị: ${_deviceCapabilities!['isDeviceSupported']}'),
                      Text('Có thể kiểm tra: ${_deviceCapabilities!['canCheckBiometrics']}'),
                      Text('Số phương thức: ${_deviceCapabilities!['availableBiometrics'].length}'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Nút xác thực chính
            ElevatedButton.icon(
              onPressed: _isAvailable ? _authenticateUser : null,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Xác thực sinh trắc học'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nút kiểm tra lại
            OutlinedButton.icon(
              onPressed: _checkAvailability,
              icon: const Icon(Icons.refresh),
              label: const Text('Kiểm tra lại thiết bị'),
            ),
            
            const SizedBox(height: 32),
            
            // Thông tin hướng dẫn
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Đảm bảo thiết bị có cảm biến vân tay hoặc camera Face ID\n'
                      '• Đã thiết lập ít nhất một vân tay trong Settings > Security\n'
                      '• Đã bật tính năng xác thực sinh trắc học trong ứng dụng\n'
                      '• Thiết bị không ở chế độ khóa sinh trắc học',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
