  class Task {
    String id;
    String title;
    String description;
    String status; // To do, In progress, Done, Cancelled
    int priority; // 1: Low, 2: Medium, 3: High
    DateTime? dueDate;
    DateTime createdAt;
    DateTime updatedAt;
    String? assignedTo; // ID của User được giao
    String createdBy; // ID của User tạo
    String? category;
    List<String>? attachments; // Danh sách file đính kèm
    bool completed;

    Task({
      required this.id,
      required this.title,
      required this.description,
      required this.status,
      required this.priority,
      this.dueDate,
      required this.createdAt,
      required this.updatedAt,
      this.assignedTo,
      required this.createdBy,
      this.category,
      this.attachments,
      required this.completed,
    });

    factory Task.fromMap(Map<String, dynamic> map) {
      return Task(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        status: map['status'] as String? ?? 'To do',
        priority: map['priority'] as int? ?? 1,
        dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
        updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
        assignedTo: map['assignedTo'] as String?,
        createdBy: map['createdBy'] as String? ?? '',
        category: map['category'] as String?,
        attachments: map['attachments'] != null && map['attachments'] is String
            ? map['attachments'].split(',')
            : [],
        completed: map['completed'] == 1 || map['completed'] == true,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'assignedTo': assignedTo,
        'createdBy': createdBy,
        'category': category,
        // Chuyển List<String> thành chuỗi phân cách bằng dấu phẩy
        'attachments': attachments != null && attachments!.isNotEmpty
            ? attachments!.join(',')
            : null,
        'completed': completed ? 1 : 0,
      };
    }

    Task copyWith({
      String? id,
      String? title,
      String? description,
      String? status,
      int? priority,
      DateTime? dueDate,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? assignedTo,
      String? createdBy,
      String? category,
      List<String>? attachments,
      bool? completed,
    }) {
      return Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        assignedTo: assignedTo ?? this.assignedTo,
        createdBy: createdBy ?? this.createdBy,
        category: category ?? this.category,
        attachments: attachments ?? this.attachments,
        completed: completed ?? this.completed,
      );
    }

    @override
    String toString() {
      return 'Task{id: $id, title: $title, status: $status, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, dueDate: $dueDate, assignedTo: $assignedTo, createdBy: $createdBy, category: $category, attachments: $attachments, completed: $completed}';
    }
  }
