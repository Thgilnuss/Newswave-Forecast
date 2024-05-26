import 'package:flutter_test/flutter_test.dart';
import 'package:tintucvathoithiet/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Kiểm thử giao diện người dùng trên các thiết bị và màn hình khác nhau', (WidgetTester tester) async {
    final screenSizes = [
      Size(320, 480),
      Size(375, 667),
      Size(414, 896),
      Size(768, 1024),
    ];

    for (var size in screenSizes) {
      tester.binding.window.physicalSizeTestValue = size;
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(MyApp());

      // Đảm bảo AppBar được hiển thị
      expect(find.byType(AppBar), findsOneWidget);

      // Đảm bảo một widget chính khác, chẳng hạn như ListView, được hiển thị
      expect(find.byType(ListView), findsOneWidget);

      // Reset lại kích thước màn hình
      tester.binding.window.clearPhysicalSizeTestValue();
    }
  });
}
