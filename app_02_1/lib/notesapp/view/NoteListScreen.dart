import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../db/NoteDatabaseHelper.dart';
import 'NoteForm.dart';
import 'NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showGrid = false;
  String _sortMode = 'time'; // 'priority' | 'time'
  String _searchText = '';
  int? _priorityFilter;

  late Future<List<Note>> _futureNotes;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      if (_searchText.isNotEmpty) {
        _futureNotes = NoteDatabaseHelper.instance.searchNotes(_searchText);
      } else if (_priorityFilter != null) {
        _futureNotes = NoteDatabaseHelper.instance.getNotesByPriority(_priorityFilter!);
      } else {
        _futureNotes = NoteDatabaseHelper.instance.getAllNotes();
      }
    });
  }

  void _onSearch(String text) {
    setState(() {
      _searchText = text;
    });
    _loadNotes();
  }

  List<Note> _applySort(List<Note> notes) {
    if (_sortMode == 'priority') {
      notes.sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }
    return notes;
  }

  void _onMenuSelect(String option) {
    setState(() {
      if (option == 'grid')        _showGrid = true;
      else if (option == 'list')   _showGrid = false;

      else if (option == 'sort_priority') _sortMode = 'priority';
      else if (option == 'sort_time')     _sortMode = 'time';

      else if (option == 'filter_1') _priorityFilter = 1;
      else if (option == 'filter_2') _priorityFilter = 2;
      else if (option == 'filter_3') _priorityFilter = 3;
      else if (option == 'filter_none') _priorityFilter = null;

      else if (option == 'refresh') {
      }
    });
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ghi chú'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelect,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Làm mới')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'sort_priority', child: Text('Sắp xếp: Tất cả')),
              const PopupMenuItem(value: 'sort_time', child: Text('Sắp xếp: Thời gian')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'filter_1', child: Text('Lọc: Ưu tiên Thấp')),
              const PopupMenuItem(value: 'filter_2', child: Text('Lọc: Ưu tiên Trung bình')),
              const PopupMenuItem(value: 'filter_3', child: Text('Lọc: Ưu tiên Cao')),
              const PopupMenuItem(value: 'filter_none', child: Text('Bỏ lọc')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'grid', child: Text('Hiển thị: Grid')),
              const PopupMenuItem(value: 'list', child: Text('Hiển thị: List')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _onSearch,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: _futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có ghi chú nào'));
          } else {
            final notes = _applySort(snapshot.data!);
            return _showGrid
                ? GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteItem(
                  note: notes[index],
                  isGridView: true,
                  onDelete: () async {
                    await NoteDatabaseHelper.instance.deleteNote(notes[index].id!);
                    _loadNotes();
                  },
                  onEdit: (note) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoteForm(note: note)),
                    ).then((_) => _loadNotes());
                  },
                );
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteItem(
                  note: notes[index],
                  isGridView: false,
                  onDelete: () async {
                    await NoteDatabaseHelper.instance.deleteNote(notes[index].id!);
                    _loadNotes();
                  },
                  onEdit: (note) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoteForm(note: note)),
                    ).then((_) => _loadNotes());
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteForm()),
          );
          if (result != null && result is Note) {
            if (result.id != null) {
              await NoteDatabaseHelper.instance.updateNote(result);
            } else {
              await NoteDatabaseHelper.instance.insertNote(result);
            }
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
