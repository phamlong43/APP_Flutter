# Tài liệu hướng dẫn triển khai chức năng admin duyệt công việc

## Tổng quan về chức năng admin

Ứng dụng này có hai loại người dùng: người dùng thông thường (user) và quản trị viên (admin). Quản trị viên có quyền phê duyệt các yêu cầu được tạo bởi người dùng thông thường.

### Các tính năng dành cho admin:

1. Xem tất cả các yêu cầu đang chờ phê duyệt từ người dùng
2. Phê duyệt hoặc từ chối các yêu cầu
3. Xem thống kê về số lượng yêu cầu đang chờ phê duyệt

## Các chức năng đã triển khai

1. **Tài khoản admin tự động**:
   - Tự động tạo tài khoản admin mặc định (username: `admin`, password: `admin123`) khi khởi động ứng dụng nếu chưa tồn tại.

2. **Xác thực và phân quyền**:
   - Khi đăng nhập, hệ thống kiểm tra vai trò của người dùng (admin hay user thông thường).
   - HomeScreen được tùy chỉnh hiển thị dựa trên vai trò người dùng.
   - Màn hình WorkApprovalScreen có cơ chế bảo vệ, chỉ cho phép admin truy cập.

3. **Màn hình duyệt yêu cầu (WorkApprovalScreen)**:
   - Hiển thị danh sách tất cả các yêu cầu đang chờ duyệt.
   - Admin có thể xem chi tiết và phê duyệt hoặc từ chối từng yêu cầu.

4. **Thông báo và hiển thị trạng thái công việc**:
   - Hiển thị số lượng công việc đang chờ duyệt trên giao diện.
   - Phân biệt trạng thái các yêu cầu bằng màu sắc khác nhau.

## Cấu trúc và thành phần

1. **Mô hình dữ liệu**:
   - Lớp `WorkItem` trong `models/work_item.dart` đại diện cho một yêu cầu.
   - Bảng `work_items` trong cơ sở dữ liệu lưu trữ thông tin chi tiết về các yêu cầu.
   - Bảng `users` đã được mở rộng với cột `role` để phân biệt admin và user thường.

2. **Database Helper**:
   - Các phương thức để truy vấn và cập nhật dữ liệu yêu cầu:
     - `createWorkItem`: Tạo yêu cầu mới
     - `getPendingWorkItems`: Lấy các yêu cầu đang chờ duyệt
     - `approveWorkItem`, `rejectWorkItem`: Phê duyệt hoặc từ chối yêu cầu
     - `countPendingWorkItems`: Đếm số lượng yêu cầu chờ duyệt

3. **Auth Service**:
   - Class hỗ trợ kiểm tra quyền admin trong ứng dụng
   - Cung cấp phương thức để bảo vệ các màn hình chỉ dành cho admin

## Luồng hoạt động

1. Người dùng khởi động ứng dụng và được đưa đến WelcomeScreen
2. Người dùng đăng nhập, hệ thống xác thực vai trò của họ
3. Nếu là admin:
   - HomeScreen hiển thị thêm phần "Phê duyệt công việc" với số lượng việc cần duyệt
   - Admin có thể truy cập WorkApprovalScreen để xử lý các yêu cầu
4. Nếu là user thông thường:
   - Người dùng có thể tạo các yêu cầu mới và xem trạng thái của chúng
   - Không thể truy cập các tính năng dành riêng cho admin

## Hướng dẫn sử dụng

### Đăng nhập với tài khoản admin
1. Mở ứng dụng, nhấn nút "Bắt đầu" từ WelcomeScreen
2. Đăng nhập với thông tin:
   - Username: `admin`
   - Password: `admin123`
3. Sau khi đăng nhập, bạn sẽ thấy HomeScreen với các tính năng dành cho admin

### Duyệt công việc (dành cho admin)
1. Từ HomeScreen, nhấn vào nút "Xem tất cả" trong phần "Phê duyệt công việc"
2. Xem danh sách các yêu cầu đang chờ duyệt
3. Nhấn vào từng yêu cầu để xem chi tiết và duyệt/từ chối

## Bảo mật

1. **Kiểm tra quyền hạn**:
   - Các màn hình dành cho admin đều có cơ chế bảo vệ, tự động kiểm tra quyền truy cập
   - Người dùng thông thường không thể truy cập các màn hình dành riêng cho admin

2. **Xử lý an toàn**:
   - Mỗi lần khởi động ứng dụng đều kiểm tra và đảm bảo tài khoản admin tồn tại
   - Các hoạt động liên quan đến quyền hạn được xác thực và ghi nhật ký
