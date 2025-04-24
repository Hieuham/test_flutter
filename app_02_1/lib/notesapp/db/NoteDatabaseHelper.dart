import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/Note.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
''');

    await _insertSampleData(db);
  }

  // Thêm dữ liệu mẫu vào database
  Future _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> sampleNotes = [
      {
        'title': 'Đọc sách',
        'content': 'Đọc xong 2 chương',
        'priority': 3,
        'createdAt': now,
        'modifiedAt': now,
        'tags': 'Học tập,Phát triển bản thân',
        'color': '#FF5722', // Cam
      },
      {
        'title': 'Tập thể dục',
        'content': 'Chạy bộ 30 phút buổi sáng',
        'priority': 2,
        'createdAt': now,
        'modifiedAt': now,
        'tags': 'Sức khỏe,Thể thao',
        'color': '#4CAF50', // Xanh lá
      },

    ];

    for (final note in sampleNotes) {
      await db.insert('notes', note);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Thêm ghi chú mới
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'modifiedAt DESC');
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

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xoá ghi chú
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
      orderBy: 'modifiedAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Tìm kiếm ghi chú theo từ khoá
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'modifiedAt DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }
}
