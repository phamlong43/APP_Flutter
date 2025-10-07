# Xác thực Sinh trắc học - Flutter App

Tính năng xác thực sinh trắc học đã được tích hợp vào ứng dụng quản lý nhân sự, cho phép sử dụng vân tay, nhận diện khuôn mặt hoặc các phương thức sinh trắc học khác để xác thực người dùng.

## 🚀 Tính năng

- ✅ Xác thực vân tay (Fingerprint)
- ✅ Xác thực khuôn mặt (Face Recognition)
- ✅ Hỗ trợ nhiều loại sinh trắc học khác nhau
- ✅ Xử lý lỗi và fallback
- ✅ Giao diện tiếng Việt
- ✅ Tích hợp với hệ thống chấm công

## 📁 Cấu trúc File

### 1. `BiometricAuthHelper` - Utility Class chính
```
lib/utils/biometric_auth_helper.dart
```

**Các phương thức chính:**
- `authenticate()` - Xác thực sinh trắc học
- `isAvailable()` - Kiểm tra khả dụng
- `getDeviceCapabilities()` - Lấy thông tin thiết bị
- `getAvailableBiometrics()` - Danh sách phương thức hỗ trợ

### 2. `BiometricAuthExample` - Màn hình demo
```
lib/screens/biometric_auth_example.dart
```

## 🔧 Cách sử dụng

### Cách 1: Sử dụng BiometricAuthHelper trực tiếp

```dart
import '../utils/biometric_auth_helper.dart';

// Xác thực người dùng
Future<void> authenticateUser() async {
  final result = await BiometricAuthHelper.authenticate(
    context: context,
    title: 'Xác thực sinh trắc học',
    subtitle: 'Dùng vân tay hoặc khuôn mặt để xác nhận danh tính',
    cancelText: 'Huỷ',
  );

  if (result) {
    // Xác thực thành công
    print('✅ User authenticated successfully!');
    // TODO: Cho phép truy cập tính năng bảo mật
  } else {
    // Xác thực thất bại
    print('❌ Authentication failed');
  }
}
```

### Cách 2: Kiểm tra khả năng thiết bị

```dart
Future<void> checkDeviceCapabilities() async {
  // Kiểm tra nhanh
  final bool available = await BiometricAuthHelper.isAvailable();
  
  if (!available) {
    print('Thiết bị không hỗ trợ xác thực sinh trắc học');
    return;
  }

  // Kiểm tra chi tiết
  final capabilities = await BiometricAuthHelper.getDeviceCapabilities();
  print('Device supported: ${capabilities['isDeviceSupported']}');
  print('Can check biometrics: ${capabilities['canCheckBiometrics']}');
  print('Available methods: ${capabilities['availableBiometrics'].length}');
}
```

## 🎯 Tích hợp trong ứng dụng

### 1. Chấm công (Check-in/Check-out)

Trong `home_screen.dart`, tính năng đã được tích hợp:

```dart
// Check-in
Future<void> _performCheckIn() async {
  final bool isAuthenticated = await BiometricAuthHelper.authenticate(
    context: context,
    title: 'Xác thực chấm công',
    subtitle: 'Dùng vân tay hoặc khuôn mặt để bắt đầu ca làm việc',
    cancelText: 'Huỷ chấm công',
  );
  
  if (isAuthenticated) {
    // Thực hiện chấm công...
  }
}

// Check-out
Future<void> _performCheckOut() async {
  final bool isAuthenticated = await BiometricAuthHelper.authenticate(
    context: context,
    title: 'Xác thực chấm công',
    subtitle: 'Dùng vân tay hoặc khuôn mặt để kết thúc ca làm việc',
    cancelText: 'Huỷ chấm công',
  );
  
  if (isAuthenticated) {
    // Thực hiện kết thúc ca...
  }
}
```

### 2. Truy cập màn hình demo

Từ menu người dùng (góc trên bên phải) → "Xác thực Sinh trắc học"

## ⚙️ Cấu hình

### Dependencies trong `pubspec.yaml`

```yaml
dependencies:
  local_auth: ^2.1.6
  local_auth_android: ^1.0.29
```

### Android Permissions

Trong `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### Tương đương với Android Native Code

Code Flutter này tương đương với Android native code:

```kotlin
// Android Native (Kotlin)
val executor = ContextCompat.getMainExecutor(this)
val biometricPrompt = BiometricPrompt(this, executor,
    object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
            // Xác thực thành công
        }
        override fun onAuthenticationFailed() {
            // Xác thực thất bại
        }
    })

val promptInfo = BiometricPrompt.PromptInfo.Builder()
    .setTitle("Xác thực sinh trắc học")
    .setSubtitle("Dùng vân tay hoặc khuôn mặt để xác nhận danh tính")
    .setNegativeButtonText("Huỷ")
    .build()

biometricPrompt.authenticate(promptInfo)
```

```dart
// Flutter (tương đương)
final result = await BiometricAuthHelper.authenticate(
  context: context,
  title: 'Xác thực sinh trắc học',
  subtitle: 'Dùng vân tay hoặc khuôn mặt để xác nhận danh tính',
  cancelText: 'Huỷ',
);
```

## 🛠️ Xử lý lỗi

BiometricAuthHelper tự động xử lý các lỗi phổ biến:

- **NotAvailable**: Thiết bị không hỗ trợ
- **NotEnrolled**: Chưa thiết lập sinh trắc học
- **LockedOut**: Bị khóa tạm thời
- **PermanentlyLockedOut**: Bị khóa vĩnh viễn
- **UserCancel**: Người dùng hủy

## 🧪 Test và Debug

### 1. Test trong ứng dụng
- Mở ứng dụng → Menu → "Xác thực Sinh trắc học"
- Nhấn nút "Xác thực sinh trắc học"

### 2. Test qua AppBar
- Nhấn icon `fingerprint` để kiểm tra khả năng thiết bị
- Nhấn icon `security` để test xác thực

### 3. Debug logs
```dart
print('Device capabilities: $capabilities');
print('Authentication result: $result');
```

## ✅ Checklist thiết lập

- [ ] Thiết bị có cảm biến vân tay/camera Face ID
- [ ] Đã thiết lập ít nhất một vân tay trong Settings > Security
- [ ] Đã bật tính năng xác thực sinh trắc học
- [ ] Dependencies đã được cài đặt trong pubspec.yaml
- [ ] Permissions đã được khai báo trong AndroidManifest.xml

## 💡 Gợi ý mở rộng

1. **Tự động xác thực**: Tự động hiện hộp thoại khi mở ứng dụng
2. **Cài đặt**: Cho phép bật/tắt xác thực sinh trắc học
3. **Fallback**: Sử dụng PIN/mật khẩu khi sinh trắc học thất bại
4. **Analytics**: Theo dõi tần suất sử dụng các phương thức xác thực
5. **Multi-factor**: Kết hợp sinh trắc học với OTP/SMS

## 🔗 Tài liệu tham khảo

- [local_auth package](https://pub.dev/packages/local_auth)
- [Android BiometricPrompt](https://developer.android.com/reference/androidx/biometric/BiometricPrompt)
- [iOS Local Authentication](https://developer.apple.com/documentation/localauthentication)
