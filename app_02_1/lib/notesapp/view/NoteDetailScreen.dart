import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02_1/notesapp/model/Note.dart';
import 'package:app_02_1/notesapp/view/NoteForm.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy HH:mm').format(date);

  @override
  Widget build(BuildContext context) {
    final priorityLabel = ['Thấp', 'Trung bình', 'Cao'][note.priority - 1];
    final priorityColor = [Colors.green, Colors.amber.shade800, Colors.red][note.priority - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NoteForm(note: note)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(note.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Ưu tiên: $priorityLabel', style: TextStyle(color: priorityColor)),
            const SizedBox(height: 8),
            Text('Tạo: ${_formatDate(note.createdAt)}', style: const TextStyle(color: Colors.grey)),
            Text('Cập nhật: ${_formatDate(note.modifiedAt)}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}