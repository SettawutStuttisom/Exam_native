import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exam/main.dart';

void main() {
  testWidgets('Add Todo Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // กดปุ่ม +
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // ใส่ข้อความ
    await tester.enterText(find.byType(TextField), 'Test Task');

    // กด Add
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // เช็คว่ามี Task นี้จริง
    expect(find.text('Test Task'), findsOneWidget);
  });
}