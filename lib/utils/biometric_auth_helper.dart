import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:flutter/services.dart';

class BiometricAuthHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Kiểm tra xem thiết bị có hỗ trợ xác thực sinh trắc học không
  static Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      return isAvailable && canCheckBiometrics && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Hiển thị hộp thoại xác thực sinh trắc học
  /// Tương tự như BiometricPrompt trong Android native
  static Future<bool> authenticate({
    required BuildContext context,
    String? title,
    String? subtitle,
    String? cancelText,
  }) async {
    try {
      // LUÔN HIỂN thị hộp thoại xác nhận cấp quyền trước
      final bool userConsent = await _showPermissionDialog(
        context: context,
        title: title ?? 'Xác thực sinh trắc học',
        subtitle: subtitle ?? 'Dùng vân tay hoặc khuôn mặt để xác nhận danh tính',
      );
      
      if (!userConsent) {
        return false; // Người dùng từ chối cấp quyền
      }
      
      // Sau khi có quyền, kiểm tra xem thiết bị có hỗ trợ không
      final bool available = await isAvailable();
      
      if (!available) {
        _showErrorDialog(
          context: context,
          title: 'Thiết bị chưa sẵn sàng',
          message: 'Thiết bị không hỗ trợ xác thực sinh trắc học hoặc chưa được thiết lập.\n\n'
              'Hãy vào Settings > Security > Fingerprint để thiết lập vân tay.',
        );
        return false;
      }

      // Thực hiện xác thực
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: subtitle ?? 'Dùng vân tay hoặc khuôn mặt để xác nhận danh tính',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Xác thực sinh trắc học',
            cancelButton: 'Huỷ',
            biometricHint: 'Đặt ngón tay lên cảm biến',
            biometricNotRecognized: 'Không khớp, thử lại!',
            biometricRequiredTitle: 'Yêu cầu sinh trắc học',
            biometricSuccess: 'Xác thực thành công!',
            deviceCredentialsRequiredTitle: 'Yêu cầu xác thực',
            deviceCredentialsSetupDescription: 'Thiết lập mã PIN, mật khẩu hoặc mẫu',
            goToSettingsButton: 'Vào cài đặt',
            goToSettingsDescription: 'Bảo mật chưa được thiết lập trên thiết bị này',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        _showSuccessDialog(context: context);
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      _handleAuthError(context, e);
      return false;
    } catch (e) {
      _showErrorDialog(
        context: context,
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi: $e',
      );
      return false;
    }
  }

  /// Xử lý các lỗi xác thực
  static void _handleAuthError(BuildContext context, PlatformException e) {
    String message;
    
    switch (e.code) {
      case 'NotAvailable':
        message = 'Xác thực sinh trắc học không khả dụng';
        break;
      case 'NotEnrolled':
        message = 'Chưa đăng ký sinh trắc học. Vui lòng thiết lập trong Cài đặt';
        break;
      case 'LockedOut':
        message = 'Quá nhiều lần thử. Vui lòng thử lại sau';
        break;
      case 'PermanentlyLockedOut':
        message = 'Sinh trắc học bị khóa vĩnh viễn. Sử dụng mật khẩu thiết bị';
        break;
      case 'BiometricOnlyNotSupported':
        message = 'Xác thực sinh trắc học không được hỗ trợ';
        break;
      case 'UserCancel':
        // Người dùng hủy, không cần hiển thị lỗi
        return;
      case 'UserFallback':
        message = 'Người dùng chọn phương thức khác';
        break;
      default:
        message = 'Lỗi: ${e.message}';
    }

    _showErrorDialog(
      context: context,
      title: 'Lỗi xác thực',
      message: message,
    );
  }

  /// Hiển thị dialog thành công
  static void _showSuccessDialog({required BuildContext context}) {
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
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Hiển thị dialog lỗi
  static void _showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Lấy danh sách các phương thức sinh trắc học có sẵn
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Kiểm tra chi tiết khả năng của thiết bị
  static Future<Map<String, dynamic>> getDeviceCapabilities() async {
    try {
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      return {
        'isDeviceSupported': isDeviceSupported,
        'canCheckBiometrics': canCheckBiometrics,
        'availableBiometrics': availableBiometrics,
        'isReady': isDeviceSupported && canCheckBiometrics && availableBiometrics.isNotEmpty,
      };
    } catch (e) {
      return {
        'isDeviceSupported': false,
        'canCheckBiometrics': false,
        'availableBiometrics': <BiometricType>[],
        'isReady': false,
        'error': e.toString(),
      };
    }
  }

  /// Hỏi người dùng có muốn bật xác thực vân tay không
  static Future<bool> askUseFingerprint(BuildContext context) async {
    final bool? agree = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác thực vân tay'),
          ],
        ),
        content: const Text(
          'Bạn có muốn bật đăng nhập bằng vân tay không?\n\n'
          'Điều này sẽ giúp bảo mật tài khoản của bạn tốt hơn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    // Nếu người dùng đồng ý, thực hiện xác thực luôn
    if (agree == true) {
      final bool authenticated = await authenticate(
        context: context,
        title: 'Thiết lập xác thực',
        subtitle: 'Xác thực để kích hoạt đăng nhập bằng vân tay',
        cancelText: 'Huỷ',
      );
      
      if (authenticated) {
        _showSuccessDialog(context: context);
        return true;
      } else {
        return false;
      }
    }
    
    return false;
  }

  /// Hỏi người dùng với callback tùy chỉnh
  static Future<void> askUseFingerprintWithCallback(
    BuildContext context,
    Future<void> Function() onAuthenticate,
  ) async {
    final bool? agree = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác thực vân tay'),
          ],
        ),
        content: const Text(
          'Bạn có muốn bật đăng nhập bằng vân tay không?\n\n'
          'Điều này sẽ giúp bảo mật tài khoản của bạn tốt hơn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (agree == true) {
      await onAuthenticate(); // Gọi callback tùy chỉnh
    }
  }

  /// Hiển thị hộp thoại xác nhận cấp quyền sinh trắc học
  static Future<bool> _showPermissionDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.fingerprint, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cấp quyền truy cập sinh trắc học',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(subtitle),
            const SizedBox(height: 16),
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
                      Icon(Icons.security, color: Colors.orange[700], size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Quyền được sử dụng để:',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Truy cập cảm biến vân tay', style: TextStyle(fontSize: 12)),
                        Text('• Sử dụng nhận diện khuôn mặt', style: TextStyle(fontSize: 12)),
                        Text('• Xác thực bảo mật chấm công', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Dữ liệu sinh trắc học chỉ được xử lý cục bộ trên thiết bị',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Từ chối'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Cấp quyền'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
