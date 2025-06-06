import 'package:flutter/material.dart';

class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> workItems = [
      {
        'title': 'Nhóm bài viết về chuyển đổi số',
        'project': 'Kế hoạch MKT HrOnline tháng 5',
        'team': 'Content',
        'date': '05/05 - 05/05',
        'qt': 'assets/user1.png',
        'th': 'assets/user2.png',
        'progress': 100,
        'color': Colors.orange
      },
      {
        'title': 'Viết bài về phần mềm Omas',
        'project': 'Omas - SME',
        'team': 'Content',
        'date': '09/04 - 09/04',
        'qt': 'assets/user3.png',
        'th': 'assets/user4.png',
        'progress': 100,
        'color': Colors.yellow
      },
      {
        'title': 'Báo cáo tổng kết tuần 14 - MKT',
        'project': 'Omas - SME',
        'team': 'Content',
        'date': '08/04 - 12/04',
        'qt': 'assets/user5.png',
        'th': 'assets/user6.png',
        'progress': 100,
        'color': Colors.green
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Công Việc'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: ListView.builder(
          itemCount: workItems.length,
          itemBuilder: (context, index) {
            final item = workItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Dự án: ${item['project']} - Nhóm công việc: ${item['team']}'),
                    Text(item['date']),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('QT: '),
                            CircleAvatar(radius: 14, backgroundImage: AssetImage(item['qt'])),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('TH: '),
                            CircleAvatar(radius: 14, backgroundImage: AssetImage(item['th'])),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: item['color']),
                          ),
                          child: Text('${item['progress']}%', style: TextStyle(color: item['color'])),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
