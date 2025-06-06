// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart'; // Đường dẫn đúng đến file main.dart

void main() {  testWidgets('Welcome screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HRManagementApp());    // Verify that our app builds successfully
    // Kiểm tra các widget cơ bản mà không cần kiểm tra chính xác nội dung
    expect(find.byType(ElevatedButton), findsOneWidget); // Phải có một nút bắt đầu
    expect(find.byType(Text), findsWidgets); // Phải có nhiều Text widget
    expect(find.byType(Column), findsWidgets); // Phải có Column layout
    
    // Add more appropriate tests for your app here
    // For now, we'll just make sure the app builds without crashing
  });
}
