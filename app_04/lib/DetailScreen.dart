import 'package:flutter/material.dart';
import 'todo.dart'; // Import class Todo

class DetailScreen extends StatelessWidget {
  final Todo todo;

  DetailScreen({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(todo.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(todo.description),
      ),
    );
  }
}