import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/User.dart';
import '../models/Task.dart';

class DatabaseHelper {
  static const String databaseName = 'task_management.db';
  static const int databaseVersion = 3;
  // Tên bảng người dùng
  static const String userTable = 'users';
  static const String userId = 'id';
  static const String userUsername = 'username';
  static const String userPassword = 'password';
  static const String userEmail = 'email';
  static const String userAvatar = 'avatar';
  static const String userCreatedAt = 'createdAt';
  static const String userLastActive = 'lastActive';

  // Tên bảng công việc
  static const String taskTable = 'tasks';
  static const String taskId = 'id';
  static const String taskTitle = 'title';
  static const String taskDescription = 'description';
  static const String taskStatus = 'status';
  static const String taskPriority = 'priority';
  static const String taskDueDate = 'dueDate';
  static const String taskCreatedAt = 'createdAt';
  static const String taskUpdatedAt = 'updatedAt';
  static const String taskAssignedTo = 'assignedTo';
  static const String taskCreatedBy = 'createdBy';
  static const String taskCategory = 'category';
  static const String taskAttachments = 'attachments';
  static const String taskCompleted = 'completed';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(path,
        version: databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade); // Added onUpgrade
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        $userId TEXT PRIMARY KEY,
        $userUsername TEXT UNIQUE NOT NULL,
        $userPassword TEXT NOT NULL,
        $userEmail TEXT UNIQUE NOT NULL,
        $userAvatar TEXT,
        $userCreatedAt TEXT NOT NULL,
        $userLastActive TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $taskTable (
        $taskId TEXT PRIMARY KEY,
        $taskTitle TEXT NOT NULL,
        $taskDescription TEXT,
        $taskStatus TEXT NOT NULL,
        $taskPriority INTEGER NOT NULL,
        $taskDueDate TEXT,
        $taskCreatedAt TEXT NOT NULL,
        $taskUpdatedAt TEXT NOT NULL,
        $taskAssignedTo TEXT,
        $taskCreatedBy TEXT NOT NULL,
        $taskCategory TEXT,
        $taskAttachments TEXT,
        $taskCompleted INTEGER NOT NULL,
        FOREIGN KEY ($taskAssignedTo) REFERENCES $userTable($userId),
        FOREIGN KEY ($taskCreatedBy) REFERENCES $userTable($userId)
      )
    ''');
    await db.execute('CREATE INDEX idx_task_status ON $taskTable ($taskStatus)');
    await db.execute('CREATE INDEX idx_task_priority ON $taskTable ($taskPriority)');
    await db.execute('CREATE INDEX idx_task_assigned_to ON $taskTable ($taskAssignedTo)');
    await db.execute('CREATE INDEX idx_task_created_by ON $taskTable ($taskCreatedBy)');
    await db.execute('CREATE INDEX idx_task_category ON $taskTable ($taskCategory)');
    await db.execute('CREATE INDEX idx_task_completed ON $taskTable ($taskCompleted)');
    await db.execute('CREATE INDEX idx_task_title ON $taskTable ($taskTitle)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $userTable ADD COLUMN $userCreatedAt TEXT NOT NULL DEFAULT \'\'');
      await db.execute('ALTER TABLE $userTable ADD COLUMN $userLastActive TEXT NOT NULL DEFAULT \'\'');
    }
  }

  // Các phương thức CRUD cho User
  Future<int> createUser(User user) async {
    final db = await database;
    try {
      return await db.insert(userTable, user.toMap());
    } catch (e) {
      print("Error inserting user: $e"); // In ra toàn bộ thông tin lỗi
      return -1; // Hoặc ném lại exception nếu bạn muốn xử lý nó ở nơi khác
    }
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: '$userId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: '$userUsername = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: '$userEmail = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      userTable,
      user.toMap(),
      where: '$userId = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      userTable,
      where: '$userId = ?',
      whereArgs: [id],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(userTable);
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }
  // Các phương thức CRUD cho Task
  Future<int> createTask(Task task) async {
    final db = await database;

    // Convert date if not null
    String? dueDateStr = task.dueDate?.toIso8601String();

    // Create task map
    Map<String, dynamic> taskMap = {
      taskId: task.id,
      taskTitle: task.title,
      taskDescription: task.description,
      taskStatus: task.status,
      taskPriority: task.priority,
      taskDueDate: dueDateStr,  // Store as string
      taskCreatedAt: task.createdAt.toIso8601String(), // Store createdAt as string
      taskUpdatedAt: task.updatedAt.toIso8601String(), // Store updatedAt as string
      taskAssignedTo: task.assignedTo,
      taskCreatedBy: task.createdBy,
      taskCategory: task.category,
      taskAttachments: task.attachments,
      taskCompleted: task.completed ? 1 : 0,  // Store as 1 (completed) or 0 (not completed)
    };

    return await db.insert(taskTable, taskMap);
  }


  Future<Task?> getTaskById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      taskTable,
      where: '$taskId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;

    // Convert date if not null
    String? dueDateStr = task.dueDate?.toIso8601String();

    Map<String, dynamic> taskMap = {
      taskId: task.id,
      taskTitle: task.title,
      taskDescription: task.description,
      taskStatus: task.status,
      taskPriority: task.priority,
      taskDueDate: dueDateStr,
      taskCreatedAt: task.createdAt.toIso8601String(),
      taskUpdatedAt: task.updatedAt.toIso8601String(),
      taskAssignedTo: task.assignedTo,
      taskCreatedBy: task.createdBy,
      taskCategory: task.category,
      taskAttachments: task.attachments,
      taskCompleted: task.completed ? 1 : 0,
    };

    return await db.update(
      taskTable,
      taskMap,
      where: '$taskId = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String taskId) async {
    final db = await database;
    return await db.delete(
      'tasks', // Tên bảng
      where: 'id = ?', // Điều kiện xóa theo ID
      whereArgs: [taskId],
    );
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(taskTable);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Phương thức tìm kiếm và lọc dữ liệu cho User
  Future<List<User>> searchUsers(String query) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: '$userUsername LIKE ? OR $userEmail LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Phương thức lọc dữ liệu cho Task
  // Phương thức lọc dữ liệu cho Task
  Future<List<Task>> filterTasks({
    String? status,
    int? priority,
    String? assignedTo,
    String? createdBy,
    String? category,
    bool? completed,
    String? title,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> arguments = [];

    // Filter by status
    if (status != null) {
      conditions.add('$taskStatus = ?');
      arguments.add(status);
    }

    // Filter by priority
    if (priority != null) {
      conditions.add('$taskPriority = ?');
      arguments.add(priority);
    }

    // Filter by assignedTo user
    if (assignedTo != null) {
      conditions.add('$taskAssignedTo = ?');
      arguments.add(assignedTo);
    }

    // Filter by createdBy user
    if (createdBy != null) {
      conditions.add('$taskCreatedBy = ?');
      arguments.add(createdBy);
    }

    // Filter by category
    if (category != null) {
      conditions.add('$taskCategory = ?');
      arguments.add(category);
    }

    // Filter by completed status
    if (completed != null) {
      conditions.add('$taskCompleted = ?');
      arguments.add(completed ? 1 : 0); // true = 1, false = 0
    }

    // Filter by title (search in task title)
    if (title != null) {
      conditions.add('$taskTitle LIKE ?');
      arguments.add('%$title%');
    }

    // Combining all conditions
    String? whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    List<Map<String, dynamic>> maps = await db.query(
      taskTable,
      where: whereClause,
      whereArgs: arguments,
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Phương thức tìm kiếm dữ liệu cho Task
  Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      taskTable,
      where: '$taskTitle LIKE ? OR $taskDescription LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Phương thức để cập nhật trạng thái của task
  Future<int> updateTaskStatus(String id, String newStatus) async {
    final db = await database;
    return await db.update(
      taskTable,
      {taskStatus: newStatus},
      where: '$taskId = ?',
      whereArgs: [id],
    );
  }
}