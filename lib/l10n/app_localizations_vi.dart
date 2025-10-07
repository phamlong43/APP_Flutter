// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý nhân sự';

  @override
  String get welcome => 'Chào mừng';

  @override
  String get login => 'Đăng nhập';

  @override
  String get username => 'Tên đăng nhập';

  @override
  String get password => 'Mật khẩu';

  @override
  String get loginSuccess => 'Đăng nhập thành công';

  @override
  String get loginFailure => 'Đăng nhập thất bại';

  @override
  String get adminAccount => 'Tài khoản admin';

  @override
  String get adminAccountCreated => 'Tài khoản admin đã được tạo thành công';

  @override
  String get adminAccountExists => 'Tài khoản admin đã tồn tại';

  @override
  String errorCheckingAdmin(Object error) {
    return 'Lỗi khi kiểm tra hoặc tạo tài khoản admin: $error';
  }
}
