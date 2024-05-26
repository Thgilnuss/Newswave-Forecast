import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tintucvathoithiet/news_screen.dart';

void main() {
  testWidgets('NewsScreen should update news content correctly when a different menu tile is selected', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewsScreen(),
      ),
    );

    // Tìm và tap vào một menu tile trong Drawer
    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();

    expect(find.text('Bị bạn thân khác giới chửi bới mà tôi vẫn muốn làm lành'), findsNothing);
    expect(find.text('3 câu nói của cha mẹ giúp trẻ tăng EQ'), findsNothing);
  });
}
