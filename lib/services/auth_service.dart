import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../screens/welcome_screen.dart';

class AuthService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Kiểm tra xem người dùng có quyền admin hay không
  static Future<bool> isUserAdmin(String username) async {
    try {
      final user = await _dbHelper.getUserByUsername(username);
      return user != null && user['role'] == 'admin';
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra quyền admin: $e');
      return false;
    }
  }

  // Kiểm tra quyền admin và chuyển hướng nếu không đủ quyền
  static Future<bool> checkAdminAccess(
    BuildContext context,
    String username, {
    bool redirectIfNotAdmin = true,
  }) async {
    final isAdmin = await isUserAdmin(username);

    if (!isAdmin && redirectIfNotAdmin && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền truy cập tính năng này'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }

    return isAdmin;
  }

  // Đăng xuất người dùng
  static void logout(BuildContext context) {
    // Có thể xóa token hoặc thông tin người dùng từ local storage ở đây

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }
}
