import 'package:flutter/material.dart';
import 'DetailScreen.dart'; // Import màn hình chi tiết
import 'todo.dart'; // Import class Todo

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<Todo> todos = List.generate(
    20,
        (i) => Todo(
      'Todo $i',
      'A description of what needs to be done for Todo $i',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Navigation Demo',
      home: TodoListScreen(todos: todos),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  final List<Todo> todos;

  TodoListScreen({Key? key, required this.todos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index].title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(todo: todos[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
