import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/main.dart'; // テスト対象のクラス

void main() {
  testWidgets('TaskListScreen Widget Test', (WidgetTester tester) async {
    // テスト用のデータを作成
    final tasks = [
      Task(id: '1', name: 'Task 1', isDone: false),
      Task(id: '2', name: 'Task 2', isDone: true),
    ];

    const filter = FilterOption.all;

    // テスト対象のWidgetを初期化
    await tester.pumpWidget(
  ProviderScope(
    overrides: [
      taskListProvider.overrideWith((ref) => TaskList(tasks)),
      filterProvider.overrideWith((ref) => filter)
    ],
    child: MaterialApp(
      home: Scaffold(
        body: TaskListScreen(),
      ),
    ),
  ),
);



    // タスクが存在することを確認
    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsOneWidget);

    // フィルターが存在することを確認
    expect(find.byWidgetPredicate((widget) => widget is DropdownButton), findsOneWidget);

  });
}