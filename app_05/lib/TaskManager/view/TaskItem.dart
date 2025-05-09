import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../view/TaskDetailScreen.dart';
import '../view/AddEditTaskScreen.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(String) onComplete;
  final Function(String) onDelete;
  final Function(Task) onEdit;
  final bool isKanbanView;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
    this.isKanbanView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Màu theo mức độ ưu tiên
    Color priorityColor;
    Color backgroundColor;
    switch (task.priority) {
      case 1:
        priorityColor = Colors.green.shade400;
        backgroundColor = Colors.green.shade100;
        break;
      case 2:
        priorityColor = Colors.orange.shade500;
        backgroundColor = Colors.orange.shade100;
        break;
      case 3:
        priorityColor = Colors.red.shade500;
        backgroundColor = Colors.red.shade100;
        break;
      default:
        priorityColor = Colors.grey.shade400;
        backgroundColor = Colors.grey.shade100;
    }

    // Màu trạng thái
    Color statusColor;
    switch (task.status) {
      case 'Cần làm':
        statusColor = Colors.blue.shade400;
        break;
      case 'Đang làm':
        statusColor = Colors.amber.shade600;
        break;
      case 'Đã xong':
        statusColor = Colors.green.shade600;
        break;
      case 'Hủy':
        statusColor = Colors.grey.shade600;
        break;
      default:
        statusColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: isKanbanView ? 4.0 : 16.0,
        ),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            SizedBox(height: 6),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  task.description!,
                  style: TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: priorityColor),
                SizedBox(width: 4),
                Text('Ưu tiên: ${task.priority}'),
              ],
            ),
            Row(
              children: [
                Icon(Icons.info, size: 16, color: statusColor),
                SizedBox(width: 4),
                Text(
                  'Trạng thái: ${task.status}',
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
            if (task.dueDate != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Hạn: ${task.dueDate!.toLocal().toString().split(' ')[0]}'),
                ],
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Hoàn thành',
                  icon: Icon(
                    task.completed ? Icons.check_box : Icons.check_box_outline_blank,
                    color: Colors.green,
                  ),
                  onPressed: () => onComplete(task.id!),
                ),
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit(task),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa công việc này không?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              onDelete(task.id!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
