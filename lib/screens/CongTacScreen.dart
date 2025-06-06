// CongTacScreen.dart
import 'package:flutter/material.dart';

class CongTacScreen extends StatelessWidget {
  const CongTacScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = [
      {'destination': 'Hà Nội', 'purpose': 'Họp đối tác', 'date': '10/06/2024'},
      {'destination': 'Đà Nẵng', 'purpose': 'Khảo sát thị trường', 'date': '14/06/2024'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Công Tác'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.flight_takeoff, color: Colors.orange),
              title: Text(trip['destination']!),
              subtitle: Text('${trip['purpose']} - ${trip['date']}'),
            ),
          );
        },
      ),
    );
  }
}
