import 'environment_config.dart';

class ApiConfig {
  // Cấu hình server API - lấy từ environment
  static String get baseHost => EnvironmentConfig.baseUrl;
  
  // Các endpoint API
  static String get userEndpoint => '$baseHost/users';
  static String get employeeEndpoint => '$baseHost/employees';
  static String get departmentEndpoint => '$baseHost/departments';
  static String get faceRegisterEndpoint => '$baseHost/api/face-register-requests';
  static String get postsEndpoint => '$baseHost/api/posts';
  static String get tasksEndpoint => '$baseHost/tasks';
  static String get requestsEndpoint => '$baseHost/requests';
  static String get chatEndpoint => '$baseHost/api/chat';
  static String get authEndpoint => '$baseHost/api/auth';
  static String get salariesEndpoint => '$baseHost/api/salaries';
  
  // Các phương thức tiện ích cho face register
  static String getFaceRegisterByUserUrl(int userId) => '$faceRegisterEndpoint/user/$userId';
  
  // Timeout cho các request
  static const Duration requestTimeout = Duration(seconds: 10);
  
  // Các phương thức tiện ích
  static String getUserUrl(String username) => '$userEndpoint/$username';
  static String getUserByIdUrl(int id) => '$userEndpoint/$id';
  static String getLoginUrl() => '$userEndpoint/login';
  static String getRegisterUrl() => '$userEndpoint/register';
  
  // Cấu hình cho development/production
  static bool get isDebugMode => true; // Thay đổi thành false cho production
  
  // Headers mặc định
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
