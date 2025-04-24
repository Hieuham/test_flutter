import 'package:app_02/notesApp/model/Note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  // Singleton Pattern để tạo một instance duy nhất cho DatabaseHelper
  NoteDatabaseHelper._init();

  // Lấy database, nếu chưa có thì tạo mới
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Mở database nếu chưa mở và trả về Database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Tạo bảng nếu chưa có
  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    priority INTEGER,
    createdAt TEXT,
    modifiedAt TEXT,
    tags TEXT,
    color TEXT
    
  )
    ''');

    await _insertSampleData(db); // Dữ liệu mẫu không còn isCompleted
  }

  // Thêm dữ liệu mẫu vào database
  Future _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> sampleNotes = [
      {
        'title': 'Học Flutter',
        'content': 'Học cách xây dựng ứng dụng Flutter cơ bản',
        'priority': 3,
        'createdAt': now,
        'modifiedAt': now,
        'tags': 'Học tập,Flutter',
        'color': '#FF0000', // Đỏ
      },
      {
        'title': 'Mua sắm',
        'content': 'Mua thực phẩm cho tuần này',
        'priority': 2,
        'createdAt': now,
        'modifiedAt': now,
        'tags': 'Cá nhân,Mua sắm',
        'color': '#FFFF00', // Vàng
      },
    ];

    for (final note in sampleNotes) {
      await db.insert('notes', note);
    }
  }

  // Thêm ghi chú mới vào database
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      return await txn.insert('notes', note.toMap());
    });
  }

  // Lấy tất cả ghi chú từ database
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Cập nhật ghi chú trong database
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xóa ghi chú trong database
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa trong title hoặc content
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

}
