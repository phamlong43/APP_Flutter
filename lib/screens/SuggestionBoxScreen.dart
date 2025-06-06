import 'package:flutter/material.dart';

class SuggestionBoxScreen extends StatelessWidget {
  const SuggestionBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _suggestionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hộp thư góp ý'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Góp ý của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _suggestionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Nhập góp ý tại đây...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final suggestion = _suggestionController.text;
                  if (suggestion.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Cảm ơn bạn đã góp ý!')),
                    );
                    _suggestionController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Gửi góp ý', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
