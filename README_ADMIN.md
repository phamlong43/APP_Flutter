# Tài liệu hướng dẫn triển khai chức năng admin duyệt công việc

## Các tính năng đã triển khai

1. **Mô hình dữ liệu**
   - Đã tạo lớp `WorkItem` trong file `lib/models/work_item.dart`
   - Đã thêm bảng `work_items` vào cơ sở dữ liệu trong `DatabaseHelper`

2. **Các phương thức cơ sở dữ liệu**
   - Thêm các phương thức trong `DatabaseHelper` để:
     - Tạo yêu cầu mới (`createWorkItem`)
     - Lấy các yêu cầu đang chờ duyệt (`getPendingWorkItems`)
     - Duyệt/từ chối yêu cầu (`approveWorkItem`, `rejectWorkItem`)
     - Đếm số lượng yêu cầu chờ duyệt (`countPendingWorkItems`)
     - Lấy yêu cầu của một người dùng cụ thể (`getUserWorkItems`)

3. **Màn hình giao diện**
   - `WorkApprovalScreen`: Màn hình cho admin duyệt công việc
   - `CreateWorkItemScreen`: Màn hình để người dùng tạo yêu cầu mới
   - `UserWorkItemsScreen`: Màn hình để người dùng xem yêu cầu của họ

## Các bước cần hoàn thiện

1. **Sửa lỗi import trong HomeScreen**
   - HomeScreen đang có lỗi do không tìm thấy một số class. Cần thêm import hoặc tạo các class còn thiếu như `WorkScheduleScreen`, `SuggestionBoxScreen`, v.v.

2. **Thử nghiệm**
   - Tạo tài khoản admin bằng cách thêm người dùng với role="admin" vào bảng users
   - Tạo một số yêu cầu từ tài khoản thường
   - Đăng nhập bằng tài khoản admin để duyệt các yêu cầu

3. **Tính năng bổ sung có thể triển khai**
   - Thông báo cho người dùng khi yêu cầu được duyệt/từ chối
   - Phân loại các yêu cầu theo nhiều loại chi tiết hơn
   - Thống kê về số lượng yêu cầu được duyệt/từ chối trong một khoảng thời gian

## Tạo tài khoản admin

Để tạo tài khoản admin, có thể sử dụng hàm registerUser trong DatabaseHelper:

```dart
final dbHelper = DatabaseHelper();
await dbHelper.registerUser('admin', 'admin123', role: 'admin');
```

## Ghi chú

- Các màn hình đã được thiết kế để phản ứng dựa trên vai trò người dùng (admin hoặc người dùng thường)
- Tương tác với cơ sở dữ liệu được xử lý bất đồng bộ để tránh làm đơ giao diện
- Người dùng thường chỉ thấy và quản lý các yêu cầu của riêng họ
- Admin có thể xem và duyệt tất cả các yêu cầu từ mọi người dùng
