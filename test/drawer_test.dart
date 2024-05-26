import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tintucvathoithiet/news_screen.dart';

void main() {
  testWidgets('CustomDrawer should display menu tiles correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomDrawer(
            onRssMenuSelected: (_) {},
          ),
        ),
      ),
    );

    // Kiểm tra xem các menu tile có hiển thị đúng không
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Thế giới'), findsOneWidget);
    expect(find.text('Thời sự'), findsOneWidget);
    expect(find.text('Kinh doanh'), findsOneWidget);
    expect(find.text('Ý kiến'), findsOneWidget);
    expect(find.text('Giải trí'), findsOneWidget);
    expect(find.text('Thể thao'), findsOneWidget);
    expect(find.text('Pháp luật'), findsOneWidget);
    expect(find.text('Giáo dục'), findsOneWidget);
    expect(find.text('Sức khỏe'), findsOneWidget);
  });
}
