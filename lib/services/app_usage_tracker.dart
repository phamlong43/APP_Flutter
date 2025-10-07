import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AppUsageTracker {
  static AppUsageTracker? _instance;
  static AppUsageTracker get instance => _instance ??= AppUsageTracker._();
  AppUsageTracker._();

  Timer? _timer;
  DateTime? _sessionStartTime;
  int _totalUsageToday = 0;
  int _currentSessionDuration = 0;
  bool _isWarningShown = false;
  
  // Callback để hiển thị cảnh báo
  Function()? _onWarning;
  Function(int minutes)? onUsageWarning;
  Function(int minutes)? onUsageLimit;

  static const int WARNING_MINUTES = 100; // Cảnh báo ở 100 phút
  static const int LIMIT_MINUTES = 120;   // Giới hạn ở 120 phút
  static const int WARNING_DURATION = WARNING_MINUTES; // Alias cho tương thích
  
  static const String _prefKey = 'app_usage_data';

  /// Khởi tạo tracker khi app bắt đầu
  Future<void> initTracker() async {
    await _loadUsageData();
    _startSession();
    _startTimer();
  }

  /// Dừng tracker khi app tắt
  Future<void> stopTracker() async {
    await _endSession();
    _timer?.cancel();
  }

  /// Bắt đầu timer để theo dõi thời gian
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_sessionStartTime != null) {
        _updateCurrentSession();
        _checkWarnings();
      }
    });
  }

  /// Cập nhật thời gian session hiện tại
  void _updateCurrentSession() {
    if (_sessionStartTime == null) return;
    
    final now = DateTime.now();
    _currentSessionDuration = now.difference(_sessionStartTime!).inMinutes;
  }

  /// Kiểm tra và hiển thị cảnh báo
  void _checkWarnings() {
    final currentTotal = (_totalUsageToday - _currentSessionDuration) + _currentSessionDuration;
    
    if (currentTotal >= WARNING_DURATION && !_isWarningShown) {
      _showUsageWarning();
      _isWarningShown = true;
    }
  }

  /// Kết thúc session
  Future<void> _endSession() async {
    if (_sessionStartTime == null) return;
    
    final sessionEnd = DateTime.now();
    final finalDuration = sessionEnd.difference(_sessionStartTime!).inMinutes;
    
    _totalUsageToday = (_totalUsageToday - _currentSessionDuration) + finalDuration;
    _currentSessionDuration = 0;
    _sessionStartTime = null;
    
    await _saveUsageData();
    print('🔴 Session ended. Total today: ${_totalUsageToday}min');
  }

  /// Bắt đầu phiên sử dụng
  void _startSession() {
    _sessionStartTime = DateTime.now();
    print('📱 App session started at: $_sessionStartTime');
  }

  /// Dừng theo dõi session
  void stopTracking() {
    if (_sessionStartTime == null) return;
    
    _timer?.cancel();
    _timer = null;
    
    // Tính thời gian session cuối cùng
    final sessionEnd = DateTime.now();
    final finalDuration = sessionEnd.difference(_sessionStartTime!).inMinutes;
    
    _totalUsageToday = (_totalUsageToday - _currentSessionDuration) + finalDuration;
    _currentSessionDuration = 0;
    _sessionStartTime = null;
    
    _saveUsageData();
    print('🔴 Stopped tracking app usage. Total today: ${_totalUsageToday}min');
  }

  /// Lấy thông tin sử dụng hiện tại
  Map<String, dynamic> getCurrentUsage() {
    int currentTotal = _totalUsageToday;
    
    // Nếu đang trong session, tính thêm thời gian hiện tại
    if (_sessionStartTime != null) {
      final currentSessionTime = DateTime.now().difference(_sessionStartTime!).inMinutes;
      currentTotal = (_totalUsageToday - _currentSessionDuration) + currentSessionTime;
    }
    
    return {
      'totalMinutesToday': currentTotal,
      'totalHoursToday': (currentTotal / 60).toStringAsFixed(1),
      'isOverLimit': currentTotal >= WARNING_DURATION,
      'remainingMinutes': WARNING_DURATION - currentTotal,
      'warningLimit': WARNING_DURATION,
    };
  }

  /// Thiết lập callback cho cảnh báo
  void setWarningCallback(Function() callback) {
    _onWarning = callback;
  }

  /// Hiển thị cảnh báo sử dụng quá lâu
  void _showUsageWarning() {
    final usage = getCurrentUsage();
    print('⚠️ USAGE WARNING: ${usage['totalMinutesToday']} minutes (${usage['totalHoursToday']} hours)');
    
    if (_onWarning != null) {
      _onWarning!();
    }
  }

  /// Lưu dữ liệu sử dụng
  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      final data = {
        'date': today,
        'totalMinutes': _totalUsageToday,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_prefKey, jsonEncode(data));
    } catch (e) {
      print('❌ Error saving usage data: $e');
    }
  }

  /// Tải dữ liệu sử dụng
  Future<void> _loadUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(_prefKey);
      
      if (dataString != null) {
        final data = jsonDecode(dataString);
        final savedDate = data['date'] as String;
        final today = DateTime.now().toIso8601String().substring(0, 10);
        
        if (savedDate == today) {
          // Cùng ngày, tiếp tục từ dữ liệu cũ
          _totalUsageToday = data['totalMinutes'] ?? 0;
          print('📊 Loaded usage data: ${_totalUsageToday} minutes today');
        } else {
          // Ngày mới, reset về 0
          _totalUsageToday = 0;
          print('📊 New day, reset usage counter');
        }
      } else {
        _totalUsageToday = 0;
        print('📊 No usage data found, starting fresh');
      }
    } catch (e) {
      print('❌ Error loading usage data: $e');
      _totalUsageToday = 0;
    }
  }

  /// Reset dữ liệu sử dụng (chỉ dùng để test)
  Future<void> resetUsageData() async {
    _totalUsageToday = 0;
    _currentSessionDuration = 0;
    _isWarningShown = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    
    print('🔄 Usage data reset');
  }

  /// Thêm thời gian test (chỉ dùng để test)
  void addTestMinutes(int minutes) {
    _totalUsageToday += minutes;
    _saveUsageData();
    
    // Kiểm tra cảnh báo
    if (_totalUsageToday >= WARNING_DURATION && !_isWarningShown) {
      _showUsageWarning();
      _isWarningShown = true;
    }
    
    print('🧪 Added ${minutes} test minutes. Total: ${_totalUsageToday}min');
  }

  /// Cleanup khi app bị đóng
  void dispose() {
    stopTracking();
  }
}
