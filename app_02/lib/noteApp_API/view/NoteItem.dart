import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/notesApp/model/Note.dart';
import 'package:app_02/notesApp/view/NoteDetailScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailScreen(note: note),
          ),
        );
      },
      child: Card(
        color: note.color != null
            ? Color(int.parse('0xFF${note.color!.replaceFirst('#', '')}'))
            : _getPriorityColor(),
        margin: const EdgeInsets.all(8),
        child: isGridView
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            if (note.tags != null && note.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 4,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                  ))
                      .toList(),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
                        actions: [
                          TextButton(
                            child: const Text('Hủy'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Xóa'),
                            onPressed: () {
                              onDelete();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        )
            : ListTile(
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (note.tags != null && note.tags!.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                  ))
                      .toList(),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(note),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
                      actions: [
                        TextButton(
                          child: const Text('Hủy'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Xóa'),
                          onPressed: () {
                            onDelete();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
