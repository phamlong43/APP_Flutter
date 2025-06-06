import 'package:flutter/material.dart';

/// File này chứa các màn hình placeholder cho các tính năng
/// chưa được triển khai đầy đủ trong ứng dụng.
/// Các màn hình này sẽ được thay thế bằng các triển khai thực tế sau này.

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              'Tính năng $title\nđang được phát triển',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tính năng này sẽ được cập nhật trong phiên bản tiếp theo',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// Các placeholder màn hình
class WorkScheduleScreen extends StatelessWidget {
  const WorkScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Lịch làm việc');
  }
}

class SuggestionBoxScreen extends StatelessWidget {
  const SuggestionBoxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Hộp thư góp ý');
  }
}

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Dự án');
  }
}

class RecruitmentScreen extends StatelessWidget {
  const RecruitmentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Tuyển dụng');
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Thông báo');
  }
}

class LichSuChamCongScreen extends StatelessWidget {
  const LichSuChamCongScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Lịch sử chấm công');
  }
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Nhiệm vụ');
  }
}

class SalaryDetailScreen extends StatelessWidget {
  const SalaryDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Chi tiết lương');
  }
}

class AdvanceRequestScreen extends StatelessWidget {
  const AdvanceRequestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Yêu cầu tạm ứng');
  }
}

class CongTacScreen extends StatelessWidget {
  const CongTacScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Công tác');
  }
}

class ChamCongHoScreen extends StatelessWidget {
  const ChamCongHoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Chấm công hộ');
  }
}

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Thông tin cá nhân');
  }
}

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Danh sách nhân viên');
  }
}

class AttendanceCalendarScreen extends StatelessWidget {
  const AttendanceCalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Lịch chấm công');
  }
}

class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Công việc');
  }
}

class InternalCommunicationScreen extends StatelessWidget {
  const InternalCommunicationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Truyền thông nội bộ');
  }
}

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Tài liệu');
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Đổi mật khẩu');
  }
}

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Nhân sự');
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Tin nhắn');
  }
}

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Yêu cầu nghỉ phép');
  }
}
