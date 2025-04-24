import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:app_02/notesApp/model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;

  const NoteForm({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _priority = 1;
  List<String> _tags = [];
  String? _color;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _tags = widget.note!.tags ?? [];
      _color = widget.note!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _color != null ? Color(int.parse('0xFF${_color!.replaceFirst('#', '')}')) : Colors.blue,
            onColorChanged: (color) {
              setState(() {
                _color = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
              });
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Xong'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: _tags.isNotEmpty ? _tags : null,
        color: _color,
      );
      Navigator.pop(context, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật ghi chú' : 'Thêm ghi chú mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Mức độ ưu tiên'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Thấp'),
                      value: 1,
                      groupValue: _priority,
                      onChanged: (value) => setState(() => _priority = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Trung bình'),
                      value: 2,
                      groupValue: _priority,
                      onChanged: (value) => setState(() => _priority = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Cao'),
                      value: 3,
                      groupValue: _priority,
                      onChanged: (value) => setState(() => _priority = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Thêm nhãn',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('Thêm'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  )).toList(),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Màu sắc: '),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: 30,
                      height: 30,
                      color: _color != null ? Color(int.parse('0xFF${_color!.replaceFirst('#', '')}')) : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isEditing ? 'CẬP NHẬT' : 'THÊM MỚI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
