import 'package:flutter/material.dart';

class InternalCommunicationScreen extends StatelessWidget {
  const InternalCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyền Thông Nội Bộ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildPostCard(
                  userName: 'Nguyễn Chí Thanh',
                  time: '22/05/2021 11:39',
                  contentTitle: 'ĐẾN GIỜ CHIA SẺ HRONLINE RỒI MN ƠI !!!',
                  contentBody:
                  'Hi everyone !\n\nNhư vậy là đã đến cuối tuần rồi.\nChúc mọi người vui vẻ và thư giãn nhé.\nĐừng quên trước khi ra về, cho HrOnline 1 lượt chia sẻ nhé\n\n(Thanh đã chia sẻ từ tối hôm qua rồi)\n\nThanks',
                  likes: 10,
                  comments: 5,
                  userAvatar: 'assets/user1.png',
                ),
                // Add more posts here
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String userName,
    required String time,
    required String contentTitle,
    required String contentBody,
    required int likes,
    required int comments,
    required String userAvatar,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: AssetImage(userAvatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$userName đã thêm: Thông báo ở chế độ công khai.',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(contentTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(contentBody),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$likes'),
                const SizedBox(width: 12),
                Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$comments'),
                const Spacer(),
                CircleAvatar(radius: 10, backgroundImage: AssetImage(userAvatar)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
