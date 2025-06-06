# Hướng dẫn kiểm thử chức năng Admin

## Tạo tài khoản Admin

1. Mở ứng dụng và vào màn hình đăng ký
2. Tài khoản admin không thể tạo từ giao diện, phải thông qua code hoặc database trực tiếp

### Cách 1: Sử dụng code để đăng ký tài khoản admin

```dart
// Tạo một hàm helper trong file main.dart hoặc một file riêng
Future<void> createAdminAccount() async {
  final dbHelper = DatabaseHelper();
  try {
    await dbHelper.registerUser('admin', 'admin123', role: 'admin');
    print('Tài khoản admin đã được tạo thành công');
  } catch (e) {
    print('Lỗi khi tạo tài khoản admin: $e');
  }
}

// Sau đó gọi hàm này khi ứng dụng khởi động (chỉ chạy một lần)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await createAdminAccount(); // Chỉ chạy một lần, sau đó comment lại
  runApp(const MyApp());
}
```

### Cách 2: Trực tiếp chỉnh sửa cơ sở dữ liệu (nếu biết vị trí file database SQLite)

1. Tìm file database SQLite của ứng dụng (thường nằm trong thư mục `/data/data/[package_name]/databases/` trên thiết bị Android)
2. Sử dụng công cụ như DB Browser for SQLite để mở và chỉnh sửa
3. Thực thi lệnh SQL để thêm tài khoản admin:
   ```sql
   INSERT INTO users (username, password, role) VALUES ('admin', 'admin123', 'admin');
   ```

## Quy trình kiểm thử

1. Đăng nhập bằng tài khoản người dùng thường (không phải admin)
   - Tạo một vài yêu cầu công việc cần duyệt
   - Kiểm tra rằng người dùng thường không thấy nút "Duyệt công việc" mà chỉ thấy nút "+"

2. Đăng xuất và đăng nhập lại bằng tài khoản admin
   - Xác nhận thông báo "Đăng nhập thành công! (Admin)" hiện ra
   - Kiểm tra rằng nút "Duyệt công việc" xuất hiện thay vì nút "+"
   - Xác nhận section "Phê duyệt công việc" hiển thị trên màn hình chính
   - Kiểm tra số lượng yêu cầu chờ duyệt hiển thị đúng

3. Duyệt các yêu cầu công việc
   - Nhấn vào nút "Duyệt công việc" hoặc "Xem tất cả"
   - Xác nhận danh sách yêu cầu hiển thị đúng
   - Thử phê duyệt một yêu cầu
   - Thử từ chối một yêu cầu khác
   - Xác nhận số lượng yêu cầu chờ duyệt giảm đi

4. Đăng xuất và đăng nhập lại bằng tài khoản người dùng thường
   - Kiểm tra trạng thái các yêu cầu đã thay đổi thành "Đã duyệt" hoặc "Từ chối"

## Ghi chú

- Mỗi lần tạo hoặc duyệt yêu cầu, hãy kiểm tra logs để đảm bảo không có lỗi nào xảy ra
- Nếu gặp lỗi, hãy kiểm tra logcat (đối với Android) hoặc console (đối với iOS) để biết thêm chi tiết
- Nếu có thay đổi trong cấu trúc database, hãy nhớ tăng phiên bản database và thêm các bước migration phù hợp

## Kiểm tra database trực tiếp (nếu cần)

Để kiểm tra database, có thể sử dụng công cụ DB Browser for SQLite mở file database và thực hiện các truy vấn:

```sql
-- Kiểm tra bảng users
SELECT * FROM users;

-- Kiểm tra bảng work_items
SELECT * FROM work_items;

-- Kiểm tra các yêu cầu đang chờ phê duyệt
SELECT * FROM work_items WHERE status = 'pending';

-- Kiểm tra các yêu cầu đã được phê duyệt
SELECT * FROM work_items WHERE status = 'approved';
```
