import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/main.dart'; // テスト対象のクラス

void main() {
  testWidgets('AddTaskScreen Widget Test', (WidgetTester tester) async {
    // テスト対象のWidgetを初期化
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AddTaskScreen(),
          ),
        ),
      ),
    );

    // テキストフィールドとボタンが存在することを確認
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // テキストフィールドにテキストを入力
    await tester.enterText(find.byType(TextField), '新しいタスク');

    // ボタンを押下
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // テキストフィールドがクリアされていることを確認
    expect(find.text('新しいタスク'), findsNothing);
  });
}
