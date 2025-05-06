import 'package:flutter/material.dart';
import '../models/Task.dart'; // Import class Task

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Công việc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.description),
            SizedBox(height: 16.0),
            Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.status),
            SizedBox(height: 16.0),
            Text('Độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${task.priority}'),
            SizedBox(height: 16.0),
            if (task.dueDate != null) ...[
              Text('Hạn hoàn thành:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.dueDate!.toLocal().toString()),
              SizedBox(height: 16.0),
            ],
            Text('Người tạo:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.createdBy),
            SizedBox(height: 16.0),
            if (task.assignedTo != null) ...[
              Text('Người được giao:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.assignedTo!),
              SizedBox(height: 16.0),
            ],
            if (task.category != null) ...[
              Text('Phân loại:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(task.category!),
              SizedBox(height: 16.0),
            ],
            if (task.attachments != null && task.attachments!.isNotEmpty) ...[
              Text('Tệp đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: task.attachments!.map((attachment) => Text(attachment)).toList(),
              ),
              SizedBox(height: 16.0),
            ],
            ElevatedButton(
              onPressed: () {
                print('Cập nhật trạng thái công việc');
              },
              child: Text('Cập nhật Trạng thái'),
            ),
          ],
        ),
      ),
    );
  }
}
