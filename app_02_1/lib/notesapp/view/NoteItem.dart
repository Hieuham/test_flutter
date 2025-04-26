import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02_1/notesapp/model/Note.dart';
import 'package:app_02_1/notesapp/view/NoteDetailScreen.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final Function(Note) onEdit;
  final bool isGridView;

  const NoteItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
    required this.isGridView,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (note.priority) {
      case 3:
        return Colors.red.shade300;
      case 2:
        return Colors.yellow.shade300;
      case 1:
      default:
        return Colors.green.shade300;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () {
            onDelete();
            Navigator.pop(context);
          }, child: const Text('Xóa')),
        ],
      ),
    );
  }

  Widget _buildTags() {
    if (note.tags == null || note.tags!.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      children: note.tags!
          .map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10))))
          .toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => onEdit(note),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = note.color != null
        ? Color(int.parse('0xFF${note.color!.replaceFirst('#', '')}'))
        : _getPriorityColor();

    final formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
        );
      },
      child: Card(
        color: backgroundColor,
        margin: const EdgeInsets.all(8),
        child: isGridView ? _buildGridContent(context, formattedTime) : _buildListContent(context, formattedTime),
      ),
    );
  }

  Widget _buildGridContent(BuildContext context, String timeText) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            note.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Content
          Text(
            note.content,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Time
          Text(
            'Cập nhật: $timeText',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Tags (shrink nếu cần)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTags(),
            ),
          ),
          const Spacer(),
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildListContent(BuildContext context, String timeText) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        note.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Cập nhật: $timeText',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          _buildTags(),
        ],
      ),
      trailing: Wrap(
        spacing: 0,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(note),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }
}