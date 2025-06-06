import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cố định hướng màn hình là dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Tạo tài khoản admin nếu chưa có (chỉ chạy một lần)
  await createAdminAccount();

  runApp(const HRManagementApp());
}

// Hàm tạo tài khoản admin nếu chưa tồn tại
Future<void> createAdminAccount() async {
  final dbHelper = DatabaseHelper();
  try {
    // Kiểm tra xem tài khoản admin đã tồn tại chưa
    final adminUser = await dbHelper.getUserByUsername('admin');
    if (adminUser == null) {
      // Nếu chưa tồn tại, tạo tài khoản admin
      await dbHelper.registerUser('admin', 'admin123', role: 'admin');
      debugPrint('Tài khoản admin đã được tạo thành công');
    } else {
      debugPrint('Tài khoản admin đã tồn tại');
    }
  } catch (e) {
    debugPrint('Lỗi khi kiểm tra hoặc tạo tài khoản admin: $e');
  }
}

class HRManagementApp extends StatelessWidget {
  const HRManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HR Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Khởi đầu là WelcomeScreen
      home: const WelcomeScreen(),
    );
  }
}
