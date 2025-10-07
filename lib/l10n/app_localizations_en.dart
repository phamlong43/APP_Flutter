// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HR Management';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginFailure => 'Login failed';

  @override
  String get adminAccount => 'Admin account';

  @override
  String get adminAccountCreated =>
      'Admin account has been created successfully';

  @override
  String get adminAccountExists => 'Admin account already exists';

  @override
  String errorCheckingAdmin(Object error) {
    return 'Error checking or creating admin account: $error';
  }
}
