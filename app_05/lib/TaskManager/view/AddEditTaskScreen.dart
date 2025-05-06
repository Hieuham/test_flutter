import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Task.dart';
import '../models/User.dart';
import '../db/DatabaseHelper.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final User? loggedInUser;
  final List<User>? availableUsers;

  const AddEditTaskScreen({Key? key, this.task, this.loggedInUser, this.availableUsers}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _status;
  int? _priority;
  DateTime? _dueDate;
  String? _assignedToId;
  String? _category;
  List<String> _attachments = [];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status ?? 'Cần làm'; // Sửa ở đây để đảm bảo không bị null
      _priority = widget.task!.priority ?? 1; // Sửa ở đây
      _dueDate = widget.task!.dueDate;
      _assignedToId = widget.task!.assignedTo;
      _category = widget.task!.category;
      _attachments = widget.task!.attachments ?? [];
    } else {
      _status = 'Cần làm'; // Giá trị mặc định
      _priority = 1; // Giá trị mặc định
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _uploadAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments.add(result.files.first.name);
        // Cần xử lý tệp đính kèm thật sự trong ứng dụng (ví dụ: lưu vào thư mục)
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newTask = Task(
        id: widget.task?.id ?? now.millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status!,
        priority: _priority!,
        dueDate: _dueDate,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
        assignedTo: _assignedToId,
        createdBy: widget.loggedInUser?.id ?? 'unknown',
        category: _category,
        attachments: _attachments,
        completed: widget.task?.completed ?? false,
      );

      if (widget.task == null) {
        await _dbHelper.createTask(newTask);
      } else {
        await _dbHelper.updateTask(newTask);
      }
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteTask() async {
    if (widget.task != null) {
      await _dbHelper.deleteTask(widget.task!.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Thêm Công việc' : 'Sửa Công việc'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.red), // Đổi thành biểu tượng xóa
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề công việc
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              SizedBox(height: 16.0),

              // Mô tả công việc
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.0),

              // Trạng thái công việc
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
                value: _status,
                items: <String>['Cần làm', 'Đang làm', 'Đã xong', 'Đã hủy']
                    .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn trạng thái' : null,
              ),
              SizedBox(height: 16.0),

              // Độ ưu tiên công việc
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Độ ưu tiên',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
                value: _priority,
                items: <int>[1, 2, 3]
                    .map((int value) => DropdownMenuItem<int>(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value),
                validator: (value) => value == null ? 'Vui lòng chọn độ ưu tiên' : null,
              ),
              SizedBox(height: 16.0),

              // Ngày đến hạn công việc
              ListTile(
                title: Text('Ngày đến hạn: ${_dueDate == null ? 'Chưa chọn' : DateFormat('yyyy-MM-dd').format(_dueDate!.toLocal())}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDueDate(context),
                contentPadding: EdgeInsets.zero,
                shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              SizedBox(height: 16.0),

              // Gán người dùng
              if (widget.availableUsers != null && widget.availableUsers!.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Gán cho người dùng',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  ),
                  value: _assignedToId,
                  items: widget.availableUsers!
                      .map((user) => DropdownMenuItem<String>(value: user.id, child: Text(user.username)))
                      .toList(),
                  onChanged: (value) => setState(() => _assignedToId = value),
                ),
              SizedBox(height: 16.0),

              // Tệp đính kèm
              Text('Tệp đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _attachments.map((attachment) => Text(attachment)).toList(),
              ),
              ElevatedButton(
                onPressed: _uploadAttachment,
                child: Text('Tải lên tệp đính kèm'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              SizedBox(height: 24.0),

              // Nút Lưu công việc
              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Lưu Công việc'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
