import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/welcome_screen.dart';
import 'services/user_api.dart';

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
  try {
    final adminUser = await UserApi.getUserByUsername('admin');
    if (adminUser == null) {
      await UserApi.registerUser('admin', 'admin123', role: 'admin');
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
      // Hỗ trợ đa ngôn ngữ
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('vi'), // Vietnamese
      ],
      locale: const Locale('vi'), // Mặc định là tiếng Việt
      // Khởi đầu là WelcomeScreen
      home: const WelcomeScreen(),
    );
  }
}
