import 'package:flutter/material.dart';
import 'package:flutter_testt/screens/AddWorkHoursScreen.dart';
import 'package:flutter_testt/screens/report_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:async';
import '../db/database_helper.dart';
import 'work_approval_screen.dart';
import 'create_work_item_screen.dart';
import 'user_work_items_screen.dart';
import 'WorkScreen.dart';
import 'internalcommunicationscreen.dart' as internal_comm;
import 'Personal_Information_View_Screen.dart';
import 'employee_list_screen.dart';
import 'welcome_screen.dart';
import 'Work_Schedule_Screen.dart';
import 'change_password_screen.dart' as real_change_password;
import 'SalaryDetailScreen.dart';
import 'LeaveRequestScreen.dart';
import 'SuggestionBoxScreen.dart';
import 'DocumentScreen.dart';
import 'AdvanceRequestScreen.dart';
import 'CongTacScreen.dart';
import 'ChamCongHoScreen.dart';
import 'ChatScreen.dart';
import 'RewardDisciplineScreen.dart';
import 'EmployeeScreen.dart';
import 'RecruitmentScreen.dart';
import 'notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'assign_task_screen.dart';
import '../services/task_api.dart';
import 'task_list_screen.dart';
import 'components/admin_stat_cards.dart';
import 'components/admin_quick_report_card.dart';
import 'components/admin_recent_activity_card.dart';
import 'admin_statistics_screen.dart';
import '../services/api_endpoints.dart';
import 'digital_signature_screen.dart';
import 'LichSuChamCongScreen.dart';
import 'AttendanceCalendarScreen.dart';
import '../utils/biometric_auth_helper.dart';
import 'biometric_auth_example.dart';
import '../services/app_usage_tracker_new.dart';
import '../widgets/usage_warning_dialog.dart';
import 'biometric_auth_page.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final String username;

  const HomeScreen({
    super.key,
    this.isAdmin = false,
    this.userId = '1',
    this.username = 'User',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = true;
  int _selectedIndex = 2;

  bool get isAdmin => widget.isAdmin;

  List<dynamic> _users = [];
  bool _isLoadingUsers = false;
  List<Map<String, dynamic>> _tasks = [];
  
  // State để theo dõi trạng thái check-in/check-out
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  bool _isPendingAuthentication = false; // Theo dõi khi đang chờ Pi4 xác thực
  Timer? _pendingCheckTimer; // Timer để kiểm tra trạng thái pending

  // Hàm lấy lời chào theo thời gian
  String _getGreetingByTime() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour >= 12 && hour < 18) {
      return 'Chào buổi chiều';
    } else if (hour >= 18 && hour < 22) {
      return 'Chào buổi tối';
    } else {
      return 'Chào bạn';
    }
  }

  // Hàm kiểm tra và hiển thị thông tin thiết bị sinh trắc học
  Future<void> _checkBiometricCapabilities() async {
    final LocalAuthentication auth = LocalAuthentication();
    
    print('=== KIỂM TRA KHẢ NĂNG SINH TRẮC HỌC THIẾT BỊ ===');
    
    // Thông tin platform
    print('📱 THÔNG TIN THIẾT BỊ:');
    print('   - Platform: ${Platform.operatingSystem}');
    print('   - Version: ${Platform.operatingSystemVersion}');
    
    try {
      // 1. Kiểm tra hỗ trợ thiết bị
      final bool isDeviceSupported = await auth.isDeviceSupported();
      print('🔍 Device supports local authentication: $isDeviceSupported');
      
      // 2. Kiểm tra khả năng sử dụng sinh trắc học
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      print('🔍 Can check biometrics: $canCheckBiometrics');
      
      // 3. Lấy danh sách các phương thức sinh trắc học có sẵn
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      print('🔍 Available biometric types:');
      if (availableBiometrics.isEmpty) {
        print('   ❌ Không có phương thức sinh trắc học nào được thiết lập');
      } else {
        for (final biometric in availableBiometrics) {
          switch (biometric) {
            case BiometricType.face:
              print('   ✅ Face ID / Face Recognition');
              break;
            case BiometricType.fingerprint:
              print('   ✅ Fingerprint / Vân tay');
              break;
            case BiometricType.iris:
              print('   ✅ Iris Recognition');
              break;
            case BiometricType.strong:
              print('   ✅ Strong Biometric (Class 3)');
              break;
            case BiometricType.weak:
              print('   ✅ Weak Biometric (Class 2)');
              break;
          }
        }
      }
      
      // 4. Kiểm tra trạng thái tổng thể
      print('📊 TỔNG KẾT:');
      print('   - Thiết bị hỗ trợ: ${isDeviceSupported ? "✅ Có" : "❌ Không"}');
      print('   - Có thể kiểm tra sinh trắc học: ${canCheckBiometrics ? "✅ Có" : "❌ Không"}');
      print('   - Số phương thức có sẵn: ${availableBiometrics.length}');
      
      if (isDeviceSupported && canCheckBiometrics && availableBiometrics.isNotEmpty) {
        print('🎉 THIẾT BỊ SẴN SÀNG CHO XÁC THỰC SINH TRẮC HỌC');
      } else {
        print('⚠️  THIẾT BỊ CHƯA SẴN SÀNG - Cần kiểm tra cài đặt');
        
        if (!isDeviceSupported) {
          print('   💡 Thiết bị không hỗ trợ xác thực cục bộ');
        }
        if (!canCheckBiometrics) {
          print('   💡 Không thể kiểm tra sinh trắc học - có thể chưa được bật trong cài đặt');
        }
        if (availableBiometrics.isEmpty) {
          print('   💡 Chưa có phương thức sinh trắc học nào được đăng ký');
          print('   💡 Hãy vào Settings > Security > Fingerprint để thiết lập');
        }
      }
      
    } catch (e) {
      print('❌ LỖI KHI KIỂM TRA SINH TRẮC HỌC: $e');
    }
    
    print('================================================');
  }

  // Hàm xác thực với quyền sinh trắc học
  Future<bool> _authenticateWithBiometrics(String action) async {
    print('🔐 Starting biometric permission request for: $action');
    
    // Bước 1: Yêu cầu quyền từ người dùng
    final bool userPermission = await _showSimpleAuthDialog(action);
    
    if (!userPermission) {
      print('🚫 User denied biometric permission');
      return false;
    }
    
    print('✅ User granted biometric permission');
    
    // Nếu người dùng đồng ý, thử xác thực sinh trắc học (tùy chọn)
    final LocalAuthentication auth = LocalAuthentication();
    
    try {
      // Kiểm tra nhanh xem có sinh trắc học không
      final bool isAvailable = await auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      
      print(' Device supports biometric: $isAvailable');
      print('� Available biometrics: ${availableBiometrics.length} methods');
      
      // Nếu có sinh trắc học, thử sử dụng (không bắt buộc)
      if (isAvailable && availableBiometrics.isNotEmpty) {
        print('🚀 Attempting optional biometric authentication...');
        
        try {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Xác thực bổ sung để $action',
            authMessages: const [
              AndroidAuthMessages(
                signInTitle: 'Xác thực nhanh (Tùy chọn)',
                cancelButton: 'Bỏ qua',
                biometricHint: 'Dùng vân tay hoặc bỏ qua',
              ),
            ],
            options: const AuthenticationOptions(
              stickyAuth: false, // Không bắt buộc
              biometricOnly: false,
              useErrorDialogs: false, // Không hiển thị lỗi
              sensitiveTransaction: false,
            ),
          );
          
          print('✅ Biometric result: $didAuthenticate');
          return true; // Luôn trả về true vì đã có user consent
        } catch (e) {
          print('⚠️  Biometric failed (not required): $e');
          return true; // Vẫn cho phép vì user đã đồng ý
        }
      } else {
        print('ℹ️  No biometrics available, using user consent only');
        return true; // Dựa trên user consent
      }
    } catch (e) {
      print('⚠️  Authentication error (fallback to user consent): $e');
      return true; // Vẫn cho phép dựa trên user consent
    }
  }

  // Hàm hiển thị dialog yêu cầu quyền sinh trắc học
  Future<bool> _showSimpleAuthDialog(String action) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Không cho phép ấn ngoài để đóng
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Cấp quyền sinh trắc học'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ứng dụng cần quyền truy cập sinh trắc học',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Để $action một cách an toàn',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
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
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Từ chối',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.security, size: 18),
            label: const Text('Cấp quyền'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Hàm hiển thị dialog hướng dẫn thiết lập sinh trắc học
  Future<bool> _showBiometricSetupDialog(String action) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cần thiết lập xác thực'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết bị chưa thiết lập xác thực sinh trắc học.\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('🔧 Để thiết lập:'),
            const SizedBox(height: 8),
            const Text('1. Vào Settings (Cài đặt)'),
            const Text('2. Chọn Security & privacy (Bảo mật)'),
            const Text('3. Chọn Fingerprint (Vân tay)'),
            const Text('4. Thêm vân tay của bạn'),
            const SizedBox(height: 12),
            const Text(
              'Hoặc bạn có thể tiếp tục mà không xác thực.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('continue'),
            child: const Text('Tiếp tục'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('settings'),
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );

    switch (result) {
      case 'continue':
        return true;
      case 'settings':
        // Thử mở cài đặt (có thể không hoạt động trên tất cả thiết bị)
        try {
          // Có thể sử dụng url_launcher để mở settings
          _showErrorDialog('Vui lòng mở Settings > Security > Fingerprint để thiết lập vân tay.');
        } catch (e) {
          _showErrorDialog('Không thể mở cài đặt tự động. Vui lòng mở thủ công.');
        }
        return false;
      default:
        return false;
    }
  }

  // Hàm hiển thị dialog xác nhận
  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Hàm hiển thị lỗi
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
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

  @override
  void initState() {
    super.initState();
    if (isAdmin) {
      _fetchUsers();
      _fetchTasks();
    }
    _checkTodayAttendanceStatus(); // Kiểm tra trạng thái chấm công hôm nay
    _checkCurrentAttendanceStatus(); // Kiểm tra trạng thái chấm công hiện tại
    _checkBiometricCapabilities(); // Kiểm tra khả năng sinh trắc học của thiết bị
    _initializeUsageTracker(); // Khởi tạo theo dõi thời lượng sử dụng
  }

  @override
  void dispose() {
    AppUsageTracker.instance.stopTracker(); // Dừng tracker khi widget bị hủy
    super.dispose();
  }

  // Khởi tạo theo dõi thời lượng sử dụng
  Future<void> _initializeUsageTracker() async {
    try {
      // Thiết lập callback cho cảnh báo
      AppUsageTracker.instance.onUsageWarning = (minutes) {
        if (mounted) {
          _showUsageWarning(minutes, isLimit: false);
        }
      };

      // Thiết lập callback cho giới hạn
      AppUsageTracker.instance.onUsageLimit = (minutes) {
        if (mounted) {
          _showUsageWarning(minutes, isLimit: true);
        }
      };

      // Khởi tạo tracker
      await AppUsageTracker.instance.initTracker();
      
      print('✅ Usage tracker initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize usage tracker: $e');
    }
  }

  // Hiển thị cảnh báo sử dụng
  void _showUsageWarning(int minutes, {bool isLimit = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isLimit, // Không cho phép đóng nếu là giới hạn
      builder: (context) => UsageWarningDialog(
        usageMinutes: minutes,
        isLimit: isLimit,
      ),
    );
  }

  // Hiển thị dialog test thời lượng sử dụng
  void _showUsageTestDialog() {
    final stats = AppUsageTracker.instance.getUsageStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer, color: Colors.green),
            SizedBox(width: 8),
            Text('Test Thời lượng sử dụng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê hiện tại:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• Thời gian đã dùng: ${stats['currentMinutes']} phút'),
            Text('• Thời gian còn lại: ${stats['remainingMinutes']} phút'),
            Text('• Trạng thái: ${stats['isOverLimit'] ? 'Vượt giới hạn' : 'Bình thường'}'),
            Text('• Đã cảnh báo: ${stats['warningShown'] ? 'Có' : 'Chưa'}'),
            Text('• Đã đạt giới hạn: ${stats['limitShown'] ? 'Có' : 'Chưa'}'),
            
            const SizedBox(height: 16),
            const Text(
              'Test các tình huống:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Nút thêm 30 phút để test cảnh báo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppUsageTracker.instance.addTestMinutes(30);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã thêm 30 phút test')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thêm 30 phút (Test cảnh báo)'),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Nút thêm 60 phút để test giới hạn  
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppUsageTracker.instance.addTestMinutes(60);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã thêm 60 phút test')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thêm 60 phút (Test giới hạn)'),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Nút reset
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await AppUsageTracker.instance.resetUsage();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔄 Đã reset dữ liệu sử dụng')),
                  );
                },
                child: const Text('Reset dữ liệu'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Function để kiểm tra trạng thái chấm công hôm nay
  Future<void> _checkTodayAttendanceStatus() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      // Danh sách endpoints để thử
      final endpointsToTry = ApiEndpoints.getAttendanceEndpoints();

      for (String endpoint in endpointsToTry) {
        try {
          String url = '$endpoint?userId=${widget.userId}&date=$today';
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            // Tìm record hôm nay
            if (data is List && data.isNotEmpty) {
              // Tìm record hôm nay - ưu tiên record có status "in"
              final todayRecords = data.where((record) => record['workingDate'] == today).toList();
              
              if (todayRecords.isNotEmpty) {
                // Tìm record đang trong quá trình xử lý (pending, in, out)
                final pendingRecord = todayRecords.firstWhere(
                  (record) {
                    String recordStatus = (record['status'] ?? '').toString().toLowerCase();
                    return (recordStatus == 'pending' || recordStatus == 'in' || recordStatus == 'out') && 
                           record['checkIn'] != null && 
                           (record['checkOut'] == null || record['checkOut'].toString().isEmpty);
                  },
                  orElse: () => null,
                );
                
                if (pendingRecord != null) {
                  String recordStatus = (pendingRecord['status'] ?? '').toString().toLowerCase();
                  setState(() {
                    _isCheckedIn = (recordStatus == 'in'); // Chỉ hiện nút "Kết thúc ca" khi status = "in"
                    _isPendingAuthentication = (recordStatus == 'pending' || recordStatus == 'out'); // Đang chờ Pi4
                    if (pendingRecord['checkIn'] != null) {
                      _checkInTime = DateTime.parse(pendingRecord['checkIn']);
                    }
                  });
                  print('DEBUG: Found record - status: ${pendingRecord['status']}, isCheckedIn: $_isCheckedIn, isPending: $_isPendingAuthentication, checkInTime: $_checkInTime');
                  
                  // Start timer nếu đang pending
                  if (_isPendingAuthentication) {
                    _startPendingCheckTimer();
                  }
                } else {
                  // Không có record đang active - kiểm tra xem có record completed không
                  final completedRecord = todayRecords.firstWhere(
                    (record) {
                      String recordStatus = (record['status'] ?? '').toString().toLowerCase();
                      return recordStatus == 'completed' && 
                             record['checkIn'] != null && 
                             record['checkOut'] != null;
                    },
                    orElse: () => null,
                  );
                  
                  setState(() {
                    _isCheckedIn = false;
                    _isPendingAuthentication = false;
                    _checkInTime = null;
                  });
                  
                  if (completedRecord != null) {
                    print('DEBUG: Found COMPLETED record - status: ${completedRecord['status']}, ready for next check-in');
                  } else {
                    print('DEBUG: Found today records but none active or completed: ${todayRecords.map((r) => r['status']).join(', ')}');
                  }
                }
              } else {
                setState(() {
                  _isCheckedIn = false;
                  _isPendingAuthentication = false;
                  _checkInTime = null;
                });
                print('DEBUG: No record found for today');
              }
            }
            break;
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      print('DEBUG: Error checking attendance status: $e');
    }
  }

  // Function để kiểm tra trạng thái chấm công hiện tại từ API
  Future<void> _checkCurrentAttendanceStatus() async {
    try {
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      
      print('DEBUG: Checking current attendance status for date: $workingDate');

      // Danh sách endpoints để thử
      final endpointsToTry = ApiEndpoints.getAttendanceEndpoints();

      // Thử từng endpoint để lấy dữ liệu
      for (String endpoint in endpointsToTry) {
        try {
          String getUrl = '$endpoint?userId=${widget.userId}&date=$workingDate';
          final response = await http.get(
            Uri.parse(getUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('DEBUG: Current attendance data: ${jsonEncode(data)}');
            
            if (data is List && data.isNotEmpty) {
              // Tìm record hôm nay có checkOut = null (đang trong ca)
              final todayRecords = data.where(
                (record) => record['workingDate'] == workingDate
              ).toList();
              
              print('DEBUG: Today records count: ${todayRecords.length}');
              
              final activeRecord = todayRecords.firstWhere(
                (record) {
                  String recordStatus = (record['status'] ?? '').toString().toLowerCase();
                  return (recordStatus == 'pending' || recordStatus == 'in' || recordStatus == 'out') && 
                         (record['checkOut'] == null || record['checkOut'].toString().isEmpty);
                },
                orElse: () => null,
              );
              
              if (activeRecord != null) {
                // Có record đang trong quá trình xử lý
                String recordStatus = (activeRecord['status'] ?? '').toString().toLowerCase();
                print('DEBUG: Found record with status "$recordStatus": ${jsonEncode(activeRecord)}');
                setState(() {
                  _isCheckedIn = (recordStatus == 'in'); // Chỉ hiện nút kết thúc ca khi status = "in"
                  _isPendingAuthentication = (recordStatus == 'pending' || recordStatus == 'out'); // Đang chờ Pi4
                  if (activeRecord['checkIn'] != null) {
                    _checkInTime = DateTime.parse(activeRecord['checkIn']);
                  }
                });
                
                // Start timer nếu đang pending
                if (_isPendingAuthentication) {
                  _startPendingCheckTimer();
                }
              } else {
                // Không có record đang trong ca
                print('DEBUG: No active record found');
                setState(() {
                  _isCheckedIn = false;
                  _isPendingAuthentication = false;
                  _checkInTime = null;
                });
              }
              
              // Hiển thị thông tin về số lần chấm công hôm nay
              if (todayRecords.length > 1) {
                print('DEBUG: Multiple attendance records today: ${todayRecords.length}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ℹ️ Hôm nay bạn đã có ${todayRecords.length} lần chấm công'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else {
              // Không có dữ liệu chấm công hôm nay
              setState(() {
                _isCheckedIn = false;
                _isPendingAuthentication = false;
                _checkInTime = null;
              });
            }
            break; // Thoát khỏi loop khi thành công
          }
        } catch (e) {
          print('DEBUG: Failed to check attendance status with endpoint $endpoint: $e');
          continue;
        }
      }
    } catch (e) {
      print('DEBUG: General error checking attendance status: $e');
    }
  }

  Future<void> _fetchUsers() async {
    setState(() { _isLoadingUsers = true; });
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.usersUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final allUsers = decoded is List ? decoded : [];
        setState(() {
          _users = allUsers.where((u) => (u['role'] ?? '').toString().toUpperCase() == 'USER').toList();
          _isLoadingUsers = false;
        });
      } else {
        setState(() { _isLoadingUsers = false; });
      }
    } catch (e) {
      setState(() { _isLoadingUsers = false; });
    }
  }

  Future<void> _fetchTasks() async {
    setState(() { });
    try {
      final tasks = await TaskApi.getAllTasks();
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      setState(() { });
    }
  }

  // Hàm test xác thực với BiometricAuthHelper mới
  Future<void> _testBiometricAuth() async {
    print('🧪 TESTING NEW BIOMETRIC AUTHENTICATION');
    
    // Sử dụng BiometricAuthHelper mới
    final bool result = await BiometricAuthHelper.authenticate(
      context: context,
      title: 'Test Xác thục Sinh trắc học',
      subtitle: 'Dùng vân tay hoặc khuôn mặt để kiểm tra hệ thống',
      cancelText: 'Huỷ test',
    );
    
    print('🧪 New BiometricAuthHelper result: $result');
    
    if (result) {
      // Thành công - hiển thị thông báo và cho phép truy cập tính năng
      _onBiometricAuthSuccess('Test hệ thống');
    }
  }

  // Callback khi xác thực sinh trắc học thành công
  void _onBiometricAuthSuccess(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Xác thực thành công cho: $action'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // TODO: Ở đây bạn có thể thêm logic để mở các tính năng bảo mật
    // Ví dụ: điểm danh, mở cửa, truy cập thông tin nhạy cảm...
    print('✅ User authenticated successfully for: $action');
  }

  // Hàm xác thực sinh trắc học cho chấm công
  Future<bool> _authenticateForAttendance() async {
    return await BiometricAuthHelper.authenticate(
      context: context,
      title: 'Xác thực chấm công',
      subtitle: 'Dùng vân tay hoặc khuôn mặt để xác nhận danh tính',
      cancelText: 'Huỷ',
    );
  }

  // Function để thực hiện check-in (vào ca)
  Future<void> _performCheckIn() async {
    print('DEBUG: Starting check-in process');

    try {
      // Lấy thông tin ngày hiện tại
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      final checkInTime = now.toIso8601String(); // Full ISO timestamp
      
      // Tạo data theo format yêu cầu
      final checkInData = {
        "user": {
          "id": int.tryParse(widget.userId) ?? 1
        },
        "workingDate": workingDate,
        "checkIn": checkInTime,
        "workingHours": 8,
        "overtimeHours": 0, // Mặc định 0, có thể tính sau
        "status": "pending" // Gửi status "pending" để chờ Pi4 xác thực → Pi4 sẽ chuyển thành "in"
      };

      print('DEBUG: Check-in data: ${jsonEncode(checkInData)}');

      // Danh sách endpoints để thử
      final endpointsToTry = ApiEndpoints.getAttendanceEndpoints();

      bool success = false;
      String lastError = '';

      // Thử từng endpoint cho đến khi thành công
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Trying check-in endpoint: $endpoint');
          
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(checkInData),
          ).timeout(const Duration(seconds: 10));

          print('DEBUG: Check-in response status: ${response.statusCode}');
          print('DEBUG: Check-in response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Verify rằng check-in đã được tạo thành công
            print('DEBUG: Verifying check-in creation...');
            
            try {
              final responseData = jsonDecode(response.body);
              print('DEBUG: Check-in response data: ${jsonEncode(responseData)}');
              
              // Kiểm tra xem record đã có ID, checkIn time và status hợp lệ
              String responseStatus = (responseData['status'] ?? '').toString().toLowerCase();
              if (responseData['id'] != null && responseData['checkIn'] != null && 
                  (responseStatus == 'pending' || responseStatus == 'in')) {
                print('DEBUG: Check-in verified successfully with ID: ${responseData['id']}, status: $responseStatus');
                success = true;
                
                // Chỉ set _isCheckedIn = true khi status là "in" (đã được Pi4 xác thực)
                // Nếu status vẫn là "pending", chờ Pi4 xác thực
                setState(() {
                  _isCheckedIn = (responseStatus == 'in');
                  _isPendingAuthentication = (responseStatus == 'pending');
                  _checkInTime = now;
                });
                
                // Start timer nếu đang pending
                if (_isPendingAuthentication) {
                  _startPendingCheckTimer();
                }
                
                String statusMessage = responseStatus == 'pending' 
                    ? 'Chờ xác thực từ Pi4...' 
                    : 'Đã vào ca làm việc!';
                    
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Điểm danh thành công lúc ${_formatTime(now)}!\n📋 $statusMessage'),
                    backgroundColor: responseStatus == 'pending' ? Colors.orange : Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                break; // Thoát khỏi loop khi thành công
              } else {
                String responseStatus = (responseData['status'] ?? '').toString().toLowerCase();
                lastError = 'Check-in response thiếu ID, checkIn time hoặc status không hợp lệ (hiện tại: $responseStatus, cần: pending/in)';
                print('DEBUG: Check-in verification failed - missing ID or checkIn');
                continue;
              }
            } catch (parseError) {
              // Nếu không parse được response nhưng status code OK - CHỈ KHI KHÔNG THỂ XÁC MINH STATUS
              print('DEBUG: Cannot parse response but status OK. Warning: Không thể xác minh status "in": $parseError');
              // Không nên assume success nếu không thể verify status
              lastError = 'Không thể xác minh status sau khi vào ca - Response không parse được';
              continue; // Thử endpoint khác thay vì assume success
            }
          } else {
            lastError = 'Status ${response.statusCode}: ${response.body}';
            continue; // Thử endpoint tiếp theo
          }
        } catch (e) {
          print('DEBUG: Check-in endpoint $endpoint failed: $e');
          lastError = e.toString();
          continue; // Thử endpoint tiếp theo
        }
      }

      // Nếu tất cả endpoints đều thất bại
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi vào ca: $lastError\nVui lòng kiểm tra server và thử lại.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Check-in general exception: $e');
      // Lỗi kết nối tổng quát
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi kết nối: $e\nVui lòng kiểm tra server và thử lại.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Function để thực hiện check-out (kết thúc ca)
  Future<void> _performCheckOut() async {
    print('DEBUG: Starting check-out process');

    try {
      final now = DateTime.now();
      final workingDate = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      final checkOutTime = now.toIso8601String(); // Full ISO timestamp

      // Tính số giờ làm việc nếu có thông tin check-in
      double workingHours = 8.0; // Mặc định 8 giờ
      if (_checkInTime != null) {
        final duration = now.difference(_checkInTime!);
        workingHours = duration.inMinutes / 60.0;
        workingHours = double.parse(workingHours.toStringAsFixed(2));
      }

      print('DEBUG: Check-out started for date: $workingDate, time: $checkOutTime');
      print('DEBUG: Working hours calculated: $workingHours');

      // Danh sách endpoints để thử
      final endpointsToTry = ApiEndpoints.getAttendanceEndpoints();

      bool success = false;
      String lastError = '';

      // Thử từng endpoint để tìm và cập nhật record hôm nay
      for (String endpoint in endpointsToTry) {
        try {
          print('DEBUG: Trying check-out with endpoint: $endpoint');
          
          // Bước 1: Tìm record hôm nay
          String getUrl = '$endpoint?userId=${widget.userId}&date=$workingDate';
          final getResponse = await http.get(
            Uri.parse(getUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (getResponse.statusCode == 200) {
            final data = jsonDecode(getResponse.body);
            
            if (data is List && data.isNotEmpty) {
              // Tìm record hôm nay có status "in" và checkOut = null (đang trong ca)
              final todayRecord = data.firstWhere(
                (record) {
                  String recordStatus = (record['status'] ?? '').toString().toLowerCase();
                  return record['workingDate'] == workingDate && 
                         recordStatus == 'in' &&
                         (record['checkOut'] == null || record['checkOut'].toString().isEmpty);
                },
                orElse: () => null,
              );
              
              if (todayRecord != null && todayRecord['id'] != null) {
                // Bước 2: Cập nhật record với status = out và checkOut time (Pi4 sẽ chuyển thành "completed")
                final updateData = {
                  "status": "out",
                  "checkOut": checkOutTime
                };

                print('DEBUG: Update data: ${jsonEncode(updateData)}');

                // Thử PUT để cập nhật
                final putResponse = await http.put(
                  Uri.parse('$endpoint/${todayRecord['id']}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode(updateData),
                ).timeout(const Duration(seconds: 10));

                print('DEBUG: Check-out PUT response status: ${putResponse.statusCode}');
                print('DEBUG: Check-out PUT response body: ${putResponse.body}');

                if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
                  // Verify rằng checkout đã được update thành công
                  print('DEBUG: Verifying checkout update...');
                  
                  // Bước 3: Kiểm tra lại record để confirm checkout đã được update
                  final verifyResponse = await http.get(
                    Uri.parse('$endpoint/${todayRecord['id']}'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ).timeout(const Duration(seconds: 10));

                  if (verifyResponse.statusCode == 200) {
                    final verifyData = jsonDecode(verifyResponse.body);
                    print('DEBUG: Verify data: ${jsonEncode(verifyData)}');
                    
                    // Kiểm tra xem status đã được update và checkOut đã được ghi nhận
                    String verifyStatus = (verifyData['status'] ?? '').toString().toLowerCase();
                    if ((verifyStatus == "out" || verifyStatus == "completed") && 
                        verifyData['checkOut'] != null && verifyData['checkOut'].toString().isNotEmpty) {
                      print('DEBUG: Checkout verified successfully - Status: ${verifyData['status']}, CheckOut: ${verifyData['checkOut']}');
                      success = true;
                      
                      // Chỉ set _isCheckedIn = false khi status là "completed" (đã được Pi4 xác thực)
                      // Nếu status vẫn là "out", chờ Pi4 xác thực
                      setState(() {
                        _isCheckedIn = (verifyStatus == "in"); // Chỉ true khi vẫn đang "in"
                        _isPendingAuthentication = (verifyStatus == "out"); // Đang chờ Pi4 xác thực kết thúc ca
                        if (verifyStatus == "completed") {
                          _checkInTime = null;
                          _isPendingAuthentication = false;
                        }
                      });
                      
                      // Start timer nếu đang pending
                      if (_isPendingAuthentication) {
                        _startPendingCheckTimer();
                      }
                      
                      String statusMessage = verifyStatus == 'out' 
                          ? 'Chờ xác thực kết thúc ca từ Pi4...' 
                          : 'Đã kết thúc ca làm việc!';
                          
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Ghi nhận kết thúc ca lúc ${_formatTime(now)}!\n📋 $statusMessage\nTổng giờ làm: ${workingHours.toStringAsFixed(2)} giờ'),
                          backgroundColor: verifyStatus == 'out' ? Colors.orange : Colors.blue,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      break;
                    } else {
                      lastError = 'Checkout chưa hoàn tất - Status hiện tại: "$verifyStatus" (cần "out" hoặc "completed"), CheckOut: ${verifyData['checkOut'] != null ? "có" : "không có"}';
                      print('DEBUG: Checkout verification failed - Status: ${verifyData['status']}, CheckOut field: ${verifyData['checkOut']}');
                      continue;
                    }
                  } else {
                    lastError = 'Không thể verify checkout - Verify Status ${verifyResponse.statusCode}';
                    print('DEBUG: Verify request failed: ${verifyResponse.statusCode}');
                    continue;
                  }
                } else {
                  lastError = 'PUT Status ${putResponse.statusCode}: ${putResponse.body}';
                  continue;
                }
              } else {
                lastError = 'Không tìm thấy record check-in hôm nay với status "in" (đã được Pi4 xác thực)';
                continue;
              }
            } else {
              lastError = 'Không có dữ liệu chấm công';
              continue;
            }
          } else {
            lastError = 'GET Status ${getResponse.statusCode}: ${getResponse.body}';
            continue;
          }
        } catch (e) {
          print('DEBUG: Check-out endpoint $endpoint failed: $e');
          lastError = e.toString();
          continue;
        }
      }

      // Nếu tất cả endpoints đều thất bại
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi kết thúc ca: $lastError\nVui lòng kiểm tra server và thử lại.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Check-out general exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi kết nối: $e\nVui lòng kiểm tra server và thử lại.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Helper function để format thời gian hiển thị
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper function để tính toán thời gian làm việc
  String _calculateWorkingHours() {
    if (_checkInTime == null) return '0.00';
    
    final now = DateTime.now();
    final duration = now.difference(_checkInTime!);
    final hours = duration.inMinutes / 60.0;
    return hours.toStringAsFixed(2);
  }

  // Helper function để start timer kiểm tra pending status
  void _startPendingCheckTimer() {
    _pendingCheckTimer?.cancel(); // Cancel timer cũ nếu có
    
    if (_isPendingAuthentication) {
      print('DEBUG: Starting pending check timer');
      _pendingCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        print('DEBUG: Checking pending status...');
        await _checkCurrentAttendanceStatus();
        
        // Nếu không còn pending, cancel timer
        if (!_isPendingAuthentication) {
          print('DEBUG: No longer pending, canceling timer');
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(widget.username),
              accountEmail: Text(isAdmin ? 'Quản trị viên' : 'Người dùng'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerSectionTitle('WORKSPACE'),
            ExpansionTile(
              leading: const Icon(Icons.extension),
              title: const Text('Tiện Ích'),
              children: [
                _buildDrawerItem(
                  Icons.chat_bubble_outline,
                  'Chat',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          userId: widget.userId,
                          isAdmin: widget.isAdmin,
                          username: widget.username,
                        ),
                      ),
                    );
                  },
                ),
                // Lịch làm
                _buildDrawerItem(
                  Icons.calendar_month,
                  'Lịch làm',
                  dense: true,
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                // Lịch làm
                _buildDrawerItem(
                  Icons.insert_drive_file,
                  'Tài Liệu',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.insert_drive_file,
                  'Hộp Thư Góp Ý',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SuggestionBoxScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('Công Việc'),
              children: [
                _buildDrawerItem(
                  Icons.assignment,
                  'Dự Án',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 0); // Chuyển đến tab Công việc (WorkScreen)
                  },
                ),

                _buildDrawerItem(
                  Icons.access_time,
                  'Chấm Công',
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LichSuChamCongScreen(
                          userId: widget.userId,
                          role: widget.isAdmin ? 'ADMIN' : 'USER',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildDrawerSectionTitle('HRM'),
            _buildDrawerItem(
              Icons.groups,
              'Nhân Sự',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeScreen()),
                );
              },
            ),

            _buildDrawerItem(
              Icons.how_to_reg,
              'Tuyển Dụng',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecruitmentScreen()),
                );
              },
            ),

            _buildDrawerSectionTitle('SYSTEM'),
            _buildDrawerItem(
              Icons.bar_chart,
              'Báo Cáo',
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()),
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          '${_getGreetingByTime()}, ${widget.username}!',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showUserMenu(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 2
          ? (isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignTaskScreen(allUsers: _users),
                      ),
                    );
                  },
                  label: const Text('Giao nhiệm vụ'),
                  icon: const Icon(Icons.assignment_turned_in),
                  backgroundColor: Colors.blue,
                )
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateWorkItemScreen(
                          userId: widget.userId,
                          userName: widget.username,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                ))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2 && isAdmin) {
            _fetchUsers();
            _fetchTasks(); // Đảm bảo luôn cập nhật số nhiệm vụ khi vào Trang chủ
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Nội bộ'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch làm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return WorkScreen(isAdmin: isAdmin);
      case 1:
        return internal_comm.InternalCommunicationScreen(isAdmin: isAdmin);
      case 2:
        return _buildMainHome();
      case 3:
        // Truyền userId (String) thành int cho employeeId/createdBy
        return WorkScheduleScreen(
          employeeId: int.tryParse(widget.userId) ?? 1,
          createdBy: int.tryParse(widget.userId) ?? 1,
        );
      case 4:
        return const NotificationScreen();
      default:
        return const Center(child: Text('Trang không tồn tại'));
    }
  }

  Widget _buildMainHome() {
    if (isAdmin) {
      // Trang chủ cho admin: Thống kê nhanh
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thống kê nhanh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            AdminStatCards(
              isLoadingUsers: _isLoadingUsers,
              onUserTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeListScreen(),
                  ),
                );
              },
              onTaskTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TaskListScreen(tasks: _tasks)));
              },
              onApprovalTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkApprovalScreen()));
              },
            ),
            const SizedBox(height: 24),
            AdminQuickReportCard(
              totalUsers: _users.length,
              totalTasks: _tasks.length,
              completedTasks: _tasks.where((t) => t['status'] == 'completed').length,
              overdueTasks: _tasks.where((t) => t['status'] == 'overdue' || (t['dueDate'] != null && DateTime.tryParse(t['dueDate']) != null && DateTime.tryParse(t['dueDate'])!.isBefore(DateTime.now()) && t['status'] != 'completed')).length,
              onLeaveUsers: _users.where((u) => (u['work_status'] ?? '').toLowerCase().contains('nghỉ')).length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminStatisticsScreen(
                      totalUsers: _users.length,
                      onLeaveUsers: _users.where((u) => (u['work_status'] ?? '').toLowerCase().contains('nghỉ')).length,
                      totalTasks: _tasks.length,
                      completedTasks: _tasks.where((t) => t['status'] == 'completed').length,
                      overdueTasks: _tasks.where((t) => t['status'] == 'overdue' || (t['dueDate'] != null && DateTime.tryParse(t['dueDate']) != null && DateTime.tryParse(t['dueDate'])!.isBefore(DateTime.now()) && t['status'] != 'completed')).length,
                      users: _users.cast<Map<String, dynamic>>(),
                      tasks: _tasks,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const AdminRecentActivityCard(),
          ],
        ),
      );
    }
    // Giao diện cho người dùng thường
    return Column(
      children: [
        // Admin approval section
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Phê duyệt công việc',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        FutureBuilder<int>(
                          future: DatabaseHelper().countPendingWorkItems(),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: count > 0 ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$count việc cần duyệt',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn có thẩm quyền phê duyệt các yêu cầu từ nhân viên.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Kiểm tra quyền admin trước khi chuyển đến màn hình phê duyệt
                          if (isAdmin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkApprovalScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Bạn không có quyền truy cập tính năng này',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),          ),

        // Hiển thị "Yêu cầu của tôi" chỉ cho người dùng thường, không phải admin
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Yêu cầu của tôi ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<int>(
                      future: DatabaseHelper().countPendingWorkItems(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => UserWorkItemsScreen(
                              userId: widget.userId,
                              userName: widget.username,
                            ),
                      ),
                    );
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(12),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              //  chức năng nghỉ phép
              _buildIconTile(
                Icons.edit_note,
                'Nghỉ phép',
                Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaveRequestScreen(),
                    ),
                  );
                },
              ),
              // Nhiệm vụ
              _buildIconTile(
                Icons.assignment_turned_in,
                'Nhiệm vụ',
                Colors.green,
                onTap: () async {
                  final tasks = await TaskApi.getTasksByUsername(widget.username);
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskListScreen(tasks: tasks),
                    ),
                  );
                },
              ),
              // chức năng bổ sung công
              _buildIconTile(
                Icons.add_circle,
                'Bổ sung công',
                Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddWorkHoursScreen(),
                    ),
                  );
                },
              ),
              // hòm thư góp ý
              _buildIconTile(
                Icons.forum,
                'Hộp thư góp ý',
                Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SuggestionBoxScreen(),
                    ),
                  );
                },
              ),

              _buildIconTile(
                Icons.attach_money,
                'Phiếu Tạm Ứng',
                Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdvanceRequestScreen(),
                    ),
                  );
                },
              ),
              //lijlich su cham cong
              _buildIconTile(
                Icons.access_time,
                'Lịch Sử Chấm Công',
                Colors.lightBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LichSuChamCongScreen(
                        userId: widget.userId,
                        role: widget.isAdmin ? 'ADMIN' : 'USER',
                      ),
                    ),
                  );
                },
              ),

              // công tác
              _buildIconTile(
                Icons.flight_takeoff,
                'Công tác',
                Colors.deepOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CongTacScreen()),
                  );
                },
              ),
              // châm công ho
              _buildIconTile(
                Icons.location_on,
                'Công tác',
                Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChamCongHoScreen()),
                  );
                },
              ),
              // chức năng chữ ký số
              // _buildIconTile(
              //   Icons.edit,
              //   'Chữ ký số',
              //   Colors.purple,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => DigitalSignatureScreen(username: widget.username),
              //       ),
              //     );
              //   },
              // ),
              // bảng công nhân viên
              // _buildIconTile(
              //   Icons.calendar_today_outlined,
              //   'Bảng công nhân viên',
              //   Colors.blue,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => const AttendanceCalendarScreen(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
        
        // Chỉ hiển thị nút chấm công cho người dùng thường (không phải admin)
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPendingAuthentication 
                    ? Colors.orange 
                    : _isCheckedIn ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _isPendingAuthentication ? null : () async {
                if (_isCheckedIn) {
                  // Hiển thị dialog xác nhận kết thúc ca
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xác nhận kết thúc ca'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thời gian kết thúc: ${_formatTime(DateTime.now())}'),
                          const SizedBox(height: 8),
                          Text('Ngày: ${DateTime.now().toIso8601String().substring(0, 10)}'),
                          const SizedBox(height: 8),
                          if (_checkInTime != null) ...[
                            Text('Thời gian vào ca: ${_formatTime(_checkInTime!)}'),
                            const SizedBox(height: 8),
                            Text('Tổng thời gian làm việc: ${_calculateWorkingHours()} giờ'),
                            const SizedBox(height: 8),
                          ],
                          const Text('Bạn có chắc muốn kết thúc ca không?'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Kết thúc Ca', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  // Nếu user xác nhận, thực hiện check-out
                  if (confirm == true) {
                    await _performCheckOut();
                  }
                } else {
                  // Hiển thị dialog xác nhận vào ca
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Xác nhận vào ca'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thời gian: ${_formatTime(DateTime.now())}'),
                          const SizedBox(height: 8),
                          Text('Ngày: ${DateTime.now().toIso8601String().substring(0, 10)}'),
                          const SizedBox(height: 8),
                          const Text('Bạn có chắc muốn vào ca không?'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Vào Ca', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  // Nếu user xác nhận, thực hiện check-in
                  if (confirm == true) {
                    await _performCheckIn();
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPendingAuthentication) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Chờ xác thực Pi4...',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ] else ...[
                    Icon(
                      _isCheckedIn ? Icons.logout : Icons.access_time,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCheckedIn ? 'Kết thúc Ca' : 'Vào Ca',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        
        // Hiển thị thông báo trạng thái chờ xác thực Pi4
        if (!isAdmin && _isPendingAuthentication)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đang chờ xác thực từ hệ thống Pi4',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vui lòng đợi xác thực hoàn tất trước khi thực hiện thao tác tiếp theo',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconTile(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder:
          (_) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Thông tin cá nhân'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalInformationViewScreen(username: widget.username),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Đổi mật khẩu'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => real_change_password.ChangePasswordScreen(username: widget.username),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Chữ ký điện tử'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DigitalSignatureScreen(username: widget.username),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Bảng công nhân viên'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceCalendarScreen(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Bảng công tăng ca'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.money_outlined),
                    title: const Text('Bảng lương nhân viên'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalaryDetailScreen(userId: int.tryParse(widget.userId) ?? 2),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('Khen thưởng & Kỷ luật'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RewardDisciplineScreen(
                            isAdmin: widget.isAdmin,
                            userId: widget.userId,
                            username: widget.username,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Danh sách nhân viên'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeListScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.fingerprint, color: Colors.orange),
                    title: const Text('Xác thực Sinh trắc học'),
                    subtitle: const Text('Demo và test tính năng bảo mật'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiometricAuthExample(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.blue),
                    title: const Text('Xác thực Đơn giản'),
                    subtitle: const Text('Giao diện xác thực sinh trắc học đơn giản'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiometricAuthPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.timer, color: Colors.green),
                    title: const Text('Test Thời lượng sử dụng'),
                    subtitle: const Text('Demo cảnh báo và giới hạn sử dụng'),
                    onTap: () {
                      Navigator.pop(context);
                      _showUsageTestDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Đăng xuất'),
                    onTap: () {
                      Navigator.pop(context); // Đóng Drawer
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

Widget _buildDrawerItem(
  IconData icon,
  String title, {
  VoidCallback? onTap,
  bool dense = false,
}) {
  return ListTile(
    dense: dense,
    leading: Icon(icon),
    title: Text(title),
    onTap: onTap,
  );
}

Widget _buildDrawerSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
    ),
  );
}