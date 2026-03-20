import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Todo {
  String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      isDone: json['isDone'],
    );
  }
}

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> todos = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔹 Save
  saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data =
        todos.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList('todos', data);
  }

  // 🔹 Load
  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('todos');

    if (data != null) {
      setState(() {
        todos = data.map((e) => Todo.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  // 🔹 Add
  addTodo(String text) {
    setState(() {
      todos.add(Todo(title: text));
    });
    saveData();
  }

  // 🔹 Delete
  deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveData();
  }

  // 🔹 Toggle
  toggleTodo(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
    saveData();
  }

  // 🔹 Edit
  editTodo(int index) {
    controller.text = todos[index].title;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Task"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                todos[index].title = controller.text;
              });
              saveData();
              Navigator.pop(context);
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> pending =
        todos.where((t) => !t.isDone).toList();
    List<Todo> done =
        todos.where((t) => t.isDone).toList();

    return Scaffold(
      appBar: AppBar(title: Text("To-Do List")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Text("⏳ Pending"),
                ...pending.map((todo) {
                  int index = todos.indexOf(todo);
                  return ListTile(
                    title: Text(todo.title),
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (_) => toggleTodo(index),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editTodo(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteTodo(index),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                Divider(),

                Text("✅ Completed"),
                ...done.map((todo) {
                  int index = todos.indexOf(todo);
                  return ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (_) => toggleTodo(index),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clear();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Add Task"),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                  onPressed: () {
                    addTodo(controller.text);
                    Navigator.pop(context);
                  },
                  child: Text("Add"),
                )
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}