class Note {
  int? id;
  String title;
  String content;
  int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  DateTime createdAt;
  DateTime modifiedAt;
  List<String>? tags;
  String? color;
  bool isCompleted; // Tính năng nâng cao: Đánh dấu hoàn thành

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
    this.isCompleted = false,
  });

  // Chuyển đối tượng thành Map để lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','), // Lưu tags dưới dạng chuỗi, phân tách bằng dấu phẩy
      'color': color,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Tạo đối tượng từ Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
      color: map['color'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Tạo bản sao với một số thuộc tính được cập nhật
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
    bool? isCompleted,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority, isCompleted: $isCompleted)';
  }
}