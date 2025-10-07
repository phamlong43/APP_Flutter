import '../config/api_config.dart';

class ApiEndpoints {
  // Base URLs
  static String get baseUrl => ApiConfig.baseHost;
  static String get usersUrl => ApiConfig.userEndpoint;
  
  // Authentication endpoints
  static String get loginUrl => '${ApiConfig.userEndpoint}/login';
  static String get registerUrl => '${ApiConfig.userEndpoint}/register';
  
  // User endpoints
  static String getUserUrl(String username) => '${ApiConfig.userEndpoint}/$username';
  static String getUserByIdUrl(int id) => '${ApiConfig.userEndpoint}/$id';
  
  // Task endpoints
  static String get tasksUrl => '${baseUrl}/tasks';
  static String get allTasksUrl => '${baseUrl}/tasks/all';
  static String get updateTaskStatusUrl => '${baseUrl}/tasks/update-status';
  
  // Attendance endpoints
  static String get attendanceUrl => '${baseUrl}/api/attendance';
  static String get attendanceAltUrl => '${baseUrl}/attendance';
  
  // Chat endpoints
  static String get chatAuthUrl => '${baseUrl}/api/auth/login';
  static String getChatConversationsUrl(String userId) => '${baseUrl}/api/chat/conversations/$userId';
  static String get chatSendUrl => '${baseUrl}/api/chat/send';
  static String getChatHistoryUrl(String user1, String user2) => 
      '${baseUrl}/api/chat/history?user1=$user1&user2=$user2';
  
  // Search endpoints
  static String getSearchUsersUrl(String query) => '${baseUrl}/api/users?search=$query';
  
  // Request endpoints
  static String get allRequestsUrl => '${baseUrl}/requests/all';
  static String getRequestApproveUrl(int requestId) => '${baseUrl}/requests/$requestId/approve';
  static String getRequestRejectUrl(int requestId) => '${baseUrl}/requests/$requestId/reject';
  
  // Posts endpoints
  static String get postsUrl => '${baseUrl}/api/posts';
  static String getPostByIdUrl(int postId) => '${baseUrl}/api/posts/$postId';
  
  // Reward & Discipline endpoints
  static String get rewardDisciplineUrl => '${baseUrl}/api/reward-discipline';
  static String getRewardDisciplineWithFilterUrl(String filter) => '${baseUrl}/api/reward-discipline$filter';
  
  // Work Schedule endpoints
  static String getWorkScheduleUrl(String employeeId) => 
      '${baseUrl}/api/workschedules?employeeId=$employeeId';
  static String get createWorkScheduleUrl => '${baseUrl}/api/workschedules';
  
  // WorkScreen endpoints
  static String get workScreenBaseUrl => baseUrl;
  
  // Helper method to get multiple attendance endpoints for fallback
  static List<String> getAttendanceEndpoints() => [
    '${baseUrl}/api/attendance',
    '${baseUrl}/attendance',
  ];
}
