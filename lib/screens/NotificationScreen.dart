import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'VÀO CA',
        'time': '15/05/2021 08:33',
        'content':
        'Vui lòng chấm công VÀO CA, giờ bắt đầu VÀO CA là 08:00. Nếu VÀO CA rồi vui lòng bỏ qua thông báo này.'
      },
      {
        'title': 'TRUYỀN THÔNG NỘI BỘ',
        'time': '14/05/2021 13:35',
        'content':
        'Nguyễn Mạnh Cường Vừa bình luận : Dạ chị trên bài viết của Nguyễn Hanh'
      },
      {
        'title': 'TRUYỀN THÔNG NỘI BỘ',
        'time': '14/05/2021 13:35',
        'content':
        'Admin HrOnline Vừa bình luận : Dạ chị trên bài viết của Nguyễn Hanh'
      },
      {
        'title': 'TRUYỀN THÔNG NỘI BỘ',
        'time': '14/05/2021 12:20',
        'content': 'Nguyễn Hanh Vừa tạo BÀI VIẾT trên mạng xã hội nội bộ'
      },
      {
        'title': 'CẤP NHẬT CHẺ ĐỘ NHÂN VIÊN',
        'time': '12/05/2021 18:02',
        'content':
        'Nguyễn Hanh Vừa CẤP NHẬT : Tạm ứng lương đợt 01 tháng 04/2021, với số tiền :4000000vnd'
      },
      {
        'title': 'Qui Trình Duyệt Phiếu Bổ Sung Công',
        'time': '10/05/2021 16:26',
        'content':
        'Don (pdcc2100381) của bạn ĐÃ ĐƯỢC phê duyệt. (ID duyệt: 002)'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              item['title']!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['time']!, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(item['content']!),
              ],
            ),
          );
        },
      ),
    );
  }
}
