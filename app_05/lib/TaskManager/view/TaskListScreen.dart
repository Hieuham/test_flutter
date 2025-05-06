import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../db/DatabaseHelper.dart';
import '../view/AddEditTaskScreen.dart';
import '../view/TaskItem.dart';
import '../models/User.dart';
import '../view/LoginScreen.dart';

class TaskListScreen extends StatefulWidget {
  final User? loggedInUser;

  TaskListScreen({this.loggedInUser});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _taskListFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String? _selectedStatus;
  String? _searchKeyword;
  bool _isKanbanView = false; // Mặc định hiển thị dạng danh sách
  final TextEditingController _searchController = TextEditingController();
  List<Task> _taskList = []; // Keep a local copy of the task list
  List<User> _userList = []; // Để chứa danh sách người dùng (nếu cần cho AddEditTaskScreen)

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadTasks();
    await _loadUsers(); // Tải danh sách người dùng nếu cần cho màn hình AddEditTaskScreen
  }

  Future<void> _loadTasks({String? status, String? keyword}) async {
    setState(() {
      _selectedStatus = status;
      _searchKeyword = keyword;
      _taskListFuture = _dbHelper.filterTasks(
        status: status,
        title: keyword?.isEmpty == true ? null : keyword,
      );
    });
    // Also update the local copy:
    _taskList = await _dbHelper.filterTasks(
      status: status,
      title: keyword?.isEmpty == true ? null : keyword,
    );
  }

  Future<void> _loadUsers() async {
    _userList = await _dbHelper.getAllUsers();
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    await _dbHelper.updateTaskStatus(taskId, newStatus);
    _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final result = await _dbHelper.deleteTask(task.id!);
      if (result > 0) {
        // Remove from the local list and then reload from database
        _taskList.removeWhere((t) => t.id == task.id);
        _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
      } else {
        _showErrorDialog('Không thể xóa công việc. Vui lòng thử lại.');
      }
    } catch (e) {
      _showErrorDialog('Đã xảy ra lỗi khi xóa công việc: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditTaskScreen(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(
          task: task,
          loggedInUser: widget.loggedInUser,
          availableUsers: _userList, // Truyền danh sách người dùng
        ),
      ),
    );
    if (result == true) {
      _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
    }
  }

  // Hàm xây dựng giao diện danh sách công việc
  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _taskList.length,
      itemBuilder: (context, index) {
        final task = _taskList[index];
        return TaskItem(
          task: task,
          onComplete: (taskId) {
            _updateTaskStatus(taskId, task.completed ? 'Cần làm' : 'Đã xong');
          },
          onDelete: (taskId) {
            final taskToDelete = _taskList.firstWhere((t) => t.id == taskId);
            _deleteTask(taskToDelete);
          },
          onEdit: _navigateToEditTaskScreen, // Truyền callback
          isKanbanView: false,
        );
      },
    );
  }

  // Hàm xây dựng giao diện bảng Kanban
  Widget _buildKanbanBoard() {
    Map<String, List<Task>> categorizedTasks = {
      'Cần làm': [],
      'Đang làm': [],
      'Đã xong': [],
      'Đã hủy': [],
    };

    for (var task in _taskList) {
      categorizedTasks[task.status]?.add(task);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categorizedTasks.entries.map((entry) {
          return Container(
            width: 250,
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.0),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: entry.value.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TaskItem(
                            task: task,
                            onComplete: (taskId) {
                              _updateTaskStatus(taskId, task.completed ? 'Cần làm' : 'Đã xong');
                            },
                            onDelete: (taskId) {
                              final taskToDelete = _taskList.firstWhere((t) => t.id == taskId);
                              _deleteTask(taskToDelete);
                            },
                            onEdit: _navigateToEditTaskScreen, // Truyền callback
                            isKanbanView: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Công việc của bạn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_column),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String status) {
              _loadTasks(status: status == 'Tất cả' ? null : status);
            },
            itemBuilder: (BuildContext context) {
              return ['Tất cả', 'Cần làm', 'Đang làm', 'Đã xong', 'Đã hủy']
                  .map((status) => PopupMenuItem(value: status, child: Text(status)))
                  .toList();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmationDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _loadTasks(status: _selectedStatus, keyword: value),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm công việc...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _loadTasks(status: _selectedStatus, keyword: null);
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  isDense: true, // Giúp icon và text không quá cách xa
                  contentPadding: EdgeInsets.symmetric(vertical: 12), // Đặt lại padding
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Task>>(
        future: _taskListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có công việc nào.'));
          } else {
            _taskList = snapshot.data!; // Cập nhật danh sách cục bộ
            return _isKanbanView ? _buildKanbanBoard() : _buildTaskList();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTaskScreen(loggedInUser: widget.loggedInUser, availableUsers: _userList),
            ),
          );
          if (result == true) {
            _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}