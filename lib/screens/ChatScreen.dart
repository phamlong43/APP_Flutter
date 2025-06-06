import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chatList = [
      {'name': 'Nguyễn Văn A', 'message': 'Bạn gửi file chưa?', 'avatar': 'assets/user1.png'},
      {'name': 'Trần Thị B', 'message': 'Sáng mai họp nhé!', 'avatar': 'assets/user2.png'},
      {'name': 'Lê Văn C', 'message': 'Ok, đã nhận.', 'avatar': 'assets/user3.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đoạn chat'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final user = chatList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(user['avatar']!),
            ),
            title: Text(user['name']!),
            subtitle: Text(user['message']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(userName: user['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatelessWidget {
  final String userName;

  const ChatDetailScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> messages = [
      {'sender': 'other', 'text': 'Bạn gửi file chấm công chưa?'},
      {'sender': 'me', 'text': 'Mình gửi rồi nhé!'},
      {'sender': 'other', 'text': 'Ok, cảm ơn bạn!'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender'] == 'me';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent.withOpacity(0.8) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text']!,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Gửi tin nhắn (demo)
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
