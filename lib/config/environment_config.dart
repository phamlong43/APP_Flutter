// File cấu hình môi trường - dễ dàng chuyển đổi giữa dev/staging/production
class EnvironmentConfig {
  // Cấu hình cho các môi trường khác nhau
  static const Map<String, String> _environments = {
    'development': 'http://192.168.100.57:8080',
    'staging': 'http://staging.yourapp.com:8080',
    'production': 'https://api.yourapp.com',
    'local': 'http://localhost:8080',
    'emulator': 'http://10.0.2.2:8080', // Cho Android Emulator
  };

  // Môi trường hiện tại - thay đổi ở đây để chuyển môi trường
  static const String currentEnvironment = 'development';
  
  // Lấy base URL theo môi trường hiện tại
  static String get baseUrl {
    return _environments[currentEnvironment] ?? _environments['development']!;
  }
  
  // Các phương thức tiện ích
  static bool get isDevelopment => currentEnvironment == 'development';
  static bool get isProduction => currentEnvironment == 'production';
  static bool get isLocal => currentEnvironment == 'local';
  
  // Debug info
  static void printCurrentConfig() {
    print('🌐 Current Environment: $currentEnvironment');
    print('🔗 Base URL: $baseUrl');
  }
}
