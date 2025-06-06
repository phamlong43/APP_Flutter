# Hướng dẫn kiểm tra chức năng admin

## Chuẩn bị

1. **Cài đặt ứng dụng**
   - Clone repository và cài đặt các dependencies:
   ```
   flutter pub get
   ```

2. **Chạy ứng dụng**
   ```
   flutter run
   ```

## Kịch bản kiểm tra chức năng admin

### 1. Tạo tài khoản admin (tự động)

- Khi khởi động ứng dụng lần đầu, hệ thống sẽ tự động tạo tài khoản admin với:
  - Username: `admin`
  - Password: `admin123`
  - Role: `admin`

### 2. Kiểm tra luồng đăng nhập cơ bản

- Khi khởi động ứng dụng, màn hình hiện ra đầu tiên phải là WelcomeScreen
- Nhấn nút "Bắt đầu" để chuyển đến màn hình đăng nhập (LoginScreen)
- Đăng nhập bằng tài khoản admin
- Xác nhận rằng bạn được chuyển đến HomeScreen với vai trò admin

### 3. Kiểm tra giao diện dành cho admin

- Khi đăng nhập với tài khoản admin, kiểm tra các phần sau trên HomeScreen:
  - Header hiển thị "Quản trị viên" dưới tên người dùng
  - Có khu vực "Phê duyệt công việc" hiển thị số lượng việc cần duyệt
  - Nút "Xem tất cả" trong khu vực phê duyệt công việc

### 4. Tạo yêu cầu để kiểm tra (từ tài khoản người dùng thông thường)

- Đăng xuất khỏi tài khoản admin
- Đăng ký một tài khoản người dùng mới hoặc đăng nhập bằng tài khoản người dùng đã có
- Tạo một vài yêu cầu khác nhau (nghỉ phép, tăng ca, công tác,...)
- Kiểm tra xem các yêu cầu đã được tạo và hiển thị trong màn hình UserWorkItemsScreen

### 5. Phê duyệt yêu cầu (từ tài khoản admin)

- Đăng xuất khỏi tài khoản người dùng
- Đăng nhập lại bằng tài khoản admin
- Kiểm tra số lượng việc cần duyệt trong HomeScreen có tăng lên không
- Nhấn vào nút "Xem tất cả" để mở WorkApprovalScreen
- Kiểm tra danh sách các yêu cầu đang chờ duyệt có hiển thị đúng không
- Chọn một yêu cầu và phê duyệt nó
- Chọn một yêu cầu khác và từ chối nó
- Kiểm tra xem số lượng việc cần duyệt có giảm sau khi phê duyệt/từ chối

### 6. Kiểm tra bảo mật

- Thử truy cập WorkApprovalScreen từ tài khoản người dùng thông thường:
  - Đăng nhập bằng tài khoản người dùng
  - Thay đổi URL hoặc sử dụng kỹ thuật khác để truy cập WorkApprovalScreen
  - Kiểm tra xem bạn có bị chuyển hướng về màn hình chính không

### 7. Kiểm tra giao diện cá nhân hóa

- Kiểm tra xem AppBar và Drawer có hiển thị tên người dùng đúng không
- Kiểm tra xem avatar có hiển thị chữ cái đầu tiên của tên người dùng không
- Kiểm tra xem có hiển thị vai trò người dùng chính xác không

## Các vấn đề cần lưu ý

- **Xử lý lỗi**: Kiểm tra xem ứng dụng có xử lý đúng cách các trường hợp lỗi không (ví dụ: mất kết nối cơ sở dữ liệu)
- **Tương thích thiết bị**: Kiểm tra trên nhiều kích thước màn hình khác nhau
- **Độ trễ**: Đảm bảo các hoạt động cơ sở dữ liệu không gây ra trễ UI đáng kể

## Các kịch bản nâng cao

- Tạo nhiều tài khoản admin và kiểm tra xem chúng có cùng quyền truy cập không
- Kiểm tra xử lý đồng thời khi nhiều admin phê duyệt cùng một yêu cầu
- Kiểm tra khả năng mở rộng với số lượng lớn yêu cầu chờ duyệt
