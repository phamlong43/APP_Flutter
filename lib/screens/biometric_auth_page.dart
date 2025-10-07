import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/biometric_auth_helper.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _status = "Chưa xác thực";

  Future<void> _authenticate() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!isDeviceSupported || !canCheckBiometrics) {
      setState(() => _status = "Thiết bị không hỗ trợ sinh trắc học");
      return;
    }

    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Xác thực để truy cập ứng dụng',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      setState(() {
        _status = didAuthenticate ? "✅ Xác thực thành công!" : "❌ Thất bại!";
      });
    } catch (e) {
      setState(() {
        _status = "Lỗi: $e";
      });
    }
  }

  // Hàm hỏi người dùng có muốn bật vân tay không
  Future<void> _askUseFingerprint() async {
    final bool result = await BiometricAuthHelper.askUseFingerprint(context);
    
    setState(() {
      _status = result 
        ? "✅ Đã bật xác thực vân tay thành công!" 
        : "❌ Người dùng từ chối hoặc xác thực thất bại";
    });
  }

  // Hàm hỏi với callback tùy chỉnh
  Future<void> _askUseFingerprintWithCallback() async {
    await BiometricAuthHelper.askUseFingerprintWithCallback(
      context,
      _authenticate, // Callback tùy chỉnh
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác thực sinh trắc học"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.fingerprint, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Nút xác thực trực tiếp
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.security),
                  label: const Text("Xác thực trực tiếp"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nút hỏi người dùng trước
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _askUseFingerprint,
                  icon: const Icon(Icons.help_outline),
                  label: const Text("Hỏi trước khi xác thực"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nút với callback tùy chỉnh
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _askUseFingerprintWithCallback,
                  icon: const Icon(Icons.settings),
                  label: const Text("Hỏi với callback"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Thông tin hướng dẫn
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Hướng dẫn sử dụng:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Xác thực trực tiếp: Mở ngay dialog xác thực'),
                    Text('• Hỏi trước: Hiện dialog hỏi ý kiến người dùng'),
                    Text('• Callback: Dùng hàm tùy chỉnh sau khi đồng ý'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
