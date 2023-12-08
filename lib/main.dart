import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Task Manager'),
        ),
        body: Column(
          children: [
            AddTaskScreen(),
            Expanded(child: TaskListScreen()),
          ],
        ),
      ),
    );
  }
}


class Task {
  String id;
  String name;
  bool isDone;

  Task({required this.id, required this.name, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDone': isDone,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isDone: map['isDone'],
    );
  }
}

// タスクリストの状態を管理するプロバイダー
final taskListProvider = StateNotifierProvider<TaskList, List<Task>>((ref) => TaskList());

// タスクリストの状態を管理するStateNotifier
class TaskList extends StateNotifier<List<Task>> {
  TaskList([List<Task>? initialTasks]) : super(initialTasks ?? []) {
    loadTasks();
  }
  // タスクをロードする非同期
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getStringList('tasks') ?? [];
    state = tasks.map((task) => Task.fromMap(jsonDecode(task))).toList();
  }

  // タスクを保存する非同期
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = state.map((task) => jsonEncode(task.toMap())).toList();
    await prefs.setStringList('tasks', tasks);
  }

  // 新しいタスクを追加する
  void addTask(String name) {
    var uuid = Uuid();
    var newId = uuid.v4();
    state = [...state, Task(id: newId, name: name)];
    saveTasks();
  }

  // タスクの完了状態を切り替える
  void toggleDone(Task task) {
    task.isDone = !task.isDone;
    state = [...state];
    saveTasks();
  }

  // タスクを削除する
  void deleteTask(Task task) {
    state = state.where((t) => t != task).toList();
    saveTasks();
  }
}
// 新しいタスクを追加する画面
class AddTaskScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newTaskTitle = textController.text;
              if (newTaskTitle.isNotEmpty) {
                ref.read(taskListProvider.notifier).addTask(newTaskTitle);
                textController.clear();
              }
            },
            child: Text('追加'),
          ),
        ],
      ),
    );
  }
}

// フィルタオプションの定義
enum FilterOption { all, completed, incomplete }

final filterProvider = StateProvider<FilterOption>((ref) => FilterOption.all);

// タスクリストを表示する画面
class TaskListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final filter = ref.watch(filterProvider);
    final filteredTasks = tasks.where((task) {
      if (filter == FilterOption.completed) {
        return task.isDone;
      } else if (filter == FilterOption.incomplete) {
        return !task.isDone;
      } else {
        return true;
      }
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0), // 左側にパディングを追加
          child: Text('タスクリスト', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0), // 左側にパディングを追加
          child: DropdownButton<FilterOption>(
            value: filter,
            onChanged: (FilterOption? newValue) {
              ref.read(filterProvider.notifier).state = newValue!;
            },
            items: <DropdownMenuItem<FilterOption>>[
              DropdownMenuItem<FilterOption>(
                value: FilterOption.all,
                child: Text('すべて'),
              ),
              DropdownMenuItem<FilterOption>(
                value: FilterOption.completed,
                child: Text('完了'),
              ),
              DropdownMenuItem<FilterOption>(
                value: FilterOption.incomplete,
                child: Text('未完了'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return ListTile(
                title: Text(task.name),
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (bool? newValue) {
                    ref.read(taskListProvider.notifier).toggleDone(task);
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    ref.read(taskListProvider.notifier).deleteTask(task);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}//
