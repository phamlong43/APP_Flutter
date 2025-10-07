import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AppUsageTracker {
  static AppUsageTracker? _instance;
  static AppUsageTracker get instance => _instance ??= AppUsageTracker._();
  AppUsageTracker._();

  Timer? _timer;
  DateTime? _sessionStartTime;
  int _dailyUsageSeconds = 0;
  String? _currentDate;
  
  // Callback để hiển thị cảnh báo
  Function(int minutes)? onUsageWarning;
  Function(int minutes)? onUsageLimit;

  static const int WARNING_MINUTES = 100; // Cảnh báo ở 100 phút
  static const int LIMIT_MINUTES = 120;   // Giới hạn ở 120 phút
  
  bool _warningShown = false;
  bool _limitShown = false;

  /// Khởi tạo tracker khi app bắt đầu
  Future<void> initTracker() async {
    await _loadDailyUsage();
    _startSession();
    _startTimer();
  }

  /// Dừng tracker khi app tắt
  Future<void> stopTracker() async {
    await _endSession();
    _timer?.cancel();
  }

  /// Bắt đầu phiên sử dụng
  void _startSession() {
    _sessionStartTime = DateTime.now();
    print('📱 App session started at: $_sessionStartTime');
  }

  /// Kết thúc phiên sử dụng
  Future<void> _endSession() async {
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      _dailyUsageSeconds += sessionDuration.inSeconds;
      await _saveDailyUsage();
      
      print('📱 Session ended. Duration: ${sessionDuration.inMinutes} minutes');
      print('📊 Total daily usage: ${(_dailyUsageSeconds / 60).round()} minutes');
    }
  }

  /// Tải dữ liệu sử dụng hằng ngày
  Future<void> _loadDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    
    // Reset nếu là ngày mới
    if (_currentDate != today) {
      _currentDate = today;
      _dailyUsageSeconds = 0;
      _warningShown = false;
      _limitShown = false;
      await prefs.setInt('daily_usage_$today', 0);
      await prefs.setBool('warning_shown_$today', false);
      await prefs.setBool('limit_shown_$today', false);
    } else {
      _dailyUsageSeconds = prefs.getInt('daily_usage_$today') ?? 0;
      _warningShown = prefs.getBool('warning_shown_$today') ?? false;
      _limitShown = prefs.getBool('limit_shown_$today') ?? false;
    }
    
    print('📊 Loaded daily usage: ${(_dailyUsageSeconds / 60).round()} minutes for $today');
  }

  /// Lưu dữ liệu sử dụng hằng ngày
  Future<void> _saveDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    
    await prefs.setInt('daily_usage_$today', _dailyUsageSeconds);
    await prefs.setBool('warning_shown_$today', _warningShown);
    await prefs.setBool('limit_shown_$today', _limitShown);
  }

  /// Bắt đầu timer theo dõi
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_sessionStartTime != null) {
        final currentUsage = DateTime.now().difference(_sessionStartTime!);
        final totalMinutes = ((_dailyUsageSeconds + currentUsage.inSeconds) / 60).round();
        
        print('⏱️  Current session: ${currentUsage.inMinutes}min, Total today: ${totalMinutes}min');
        
        // Kiểm tra cảnh báo
        if (!_warningShown && totalMinutes >= WARNING_MINUTES) {
          _warningShown = true;
          await _saveDailyUsage();
          onUsageWarning?.call(totalMinutes);
          print('⚠️  Usage warning triggered at $totalMinutes minutes');
        }
        
        // Kiểm tra giới hạn
        if (!_limitShown && totalMinutes >= LIMIT_MINUTES) {
          _limitShown = true;
          await _saveDailyUsage();
          onUsageLimit?.call(totalMinutes);
          print('🚨 Usage limit triggered at $totalMinutes minutes');
        }
      }
    });
  }

  /// Lấy chuỗi ngày hiện tại
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Lấy thời gian sử dụng hiện tại (phút)
  int getCurrentUsageMinutes() {
    if (_sessionStartTime == null) return (_dailyUsageSeconds / 60).round();
    
    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    return ((_dailyUsageSeconds + sessionDuration.inSeconds) / 60).round();
  }

  /// Lấy thời gian còn lại đến giới hạn (phút)
  int getRemainingMinutes() {
    final current = getCurrentUsageMinutes();
    return LIMIT_MINUTES - current;
  }

  /// Kiểm tra có vượt giới hạn không
  bool isOverLimit() {
    return getCurrentUsageMinutes() >= LIMIT_MINUTES;
  }

  /// Reset dữ liệu sử dụng (cho testing)
  Future<void> resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    
    _dailyUsageSeconds = 0;
    _warningShown = false;
    _limitShown = false;
    _sessionStartTime = DateTime.now();
    
    await prefs.setInt('daily_usage_$today', 0);
    await prefs.setBool('warning_shown_$today', false);
    await prefs.setBool('limit_shown_$today', false);
    
    print('🔄 Usage data reset for $today');
  }

  /// Lấy thống kê sử dụng
  Map<String, dynamic> getUsageStats() {
    final current = getCurrentUsageMinutes();
    final remaining = getRemainingMinutes();
    
    return {
      'currentMinutes': current,
      'remainingMinutes': remaining > 0 ? remaining : 0,
      'isOverLimit': isOverLimit(),
      'warningShown': _warningShown,
      'limitShown': _limitShown,
      'date': _getTodayString(),
    };
  }

  /// Thêm thời gian test (cho demo)
  void addTestMinutes(int minutes) {
    _dailyUsageSeconds += minutes * 60;
    _saveDailyUsage();
    print('🧪 Added $minutes test minutes. Total: ${getCurrentUsageMinutes()} minutes');
  }
}
