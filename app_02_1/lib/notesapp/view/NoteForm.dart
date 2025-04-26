import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:app_02_1/notesapp/model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;

  const NoteForm({Key? key, this.note}) : super(key: key);

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  int _priority = 1;
  Color _selectedColor = Colors.green.shade300;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _selectedColor = widget.note!.color != null
          ? Color(int.parse('0xFF${widget.note!.color!.replaceFirst('#', '')}'))
          : Colors.green.shade300;
      _tags = List.from(widget.note!.tags ?? []);
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Xong'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final newNote = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        tags: _tags,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      Navigator.pop(context, newNote);
    }
  }

  void _addTag() {
    final newTag = _tagController.text.trim();
    if (newTag.isNotEmpty && !_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),

              const SizedBox(height: 16),

              // Nội dung
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 16),
              // Mức độ ưu tiên
              DropdownButtonFormField<int>(
                value: _priority,
                items: [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) => setState(() => _priority = value!),
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Chọn màu
              Row(
                children: [
                  const Text('Màu sắc:'),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Nhãn
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
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                children: _tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(isEditing ? 'CẬP NHẬT' : 'LƯU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}