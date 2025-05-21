import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Giả sử bạn có màn login
import 'screens/welcome_screen.dart';
void main() {
  runApp(const HRManagementApp());
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
      // Khởi đầu là WelcomeScreen thay vì HomeScreen trực tiếp
      home: const WelcomeScreen(),
    );
  }
}

// Màn hình Welcome với nền ảnh và nút bắt đầu
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4), // Mờ nền
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 150),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Khi bấm nút Bắt đầu sẽ chuyển sang màn hình đăng nhập
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
