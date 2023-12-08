import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart'; // テスト対象のクラス

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Taskクラスのテスト', () {
    // Taskインスタンスの作成
    var task = Task(id: '1', name: 'Test task');

    // idとnameが正しく設定されていることを確認
    expect(task.id, '1');
    expect(task.name, 'Test task');

    // isDoneがデフォルトでfalseであることを確認
    expect(task.isDone, false);

    // isDoneをtrueに変更
    task.isDone = true;

    // isDoneが正しく変更されていることを確認
    expect(task.isDone, true);
  });

  test('TaskListクラスのテスト', () {
    // TaskListインスタンスの作成
    var taskList = TaskList();

    // 初期状態ではタスクリストが空であることを確認
    expect(taskList.state, []);

    // タスクを追加
    taskList.addTask('Test task');

    // タスクが正しく追加されていることを確認
    expect(taskList.state.length, 1);
    expect(taskList.state[0].name, 'Test task');

    // タスクを削除
    var task = taskList.state[0];
    taskList.deleteTask(task);

    // タスクが正しく削除されていることを確認
    expect(taskList.state, []);
  });
}
