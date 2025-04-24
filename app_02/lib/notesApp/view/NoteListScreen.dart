import 'package:flutter/material.dart';
import 'package:app_02/notesApp/db/NoteDatabaseHelper.dart';
import 'package:app_02/notesApp/model/Note.dart';
import 'package:app_02/notesApp/view/NoteForm.dart';
import 'package:app_02/notesApp/view/NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  bool _isGridView = false;
  int? _filterPriority;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  String _sortBy = 'priority';

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }


  void _refreshNotes() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _notesFuture = NoteDatabaseHelper.instance.searchNotes(_searchQuery);
      } else if (_filterPriority != null) {
        _notesFuture = NoteDatabaseHelper.instance.getNotesByPriority(_filterPriority!);
      } else {
        _notesFuture = NoteDatabaseHelper.instance.getAllNotes();
      }
    });
  }

  List<Note> _sortNotes(List<Note> notes) {
    if (_sortBy == 'priority') {
      return notes..sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      return notes..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ghi chú'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'refresh':
                    _refreshNotes();
                    break;
                  case 'grid':
                    _isGridView = true;
                    break;
                  case 'list':
                    _isGridView = false;
                    break;
                  case 'sort_priority':
                    _sortBy = 'priority';
                    break;
                  case 'sort_time':
                    _sortBy = 'time';
                    break;
                  case 'filter_low':
                    _filterPriority = 1;
                    _refreshNotes();
                    break;
                  case 'filter_medium':
                    _filterPriority = 2;
                    _refreshNotes();
                    break;
                  case 'filter_high':
                    _filterPriority = 3;
                    _refreshNotes();
                    break;
                  case 'filter_none':
                    _filterPriority = null;
                    _refreshNotes();
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Làm mới')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'sort_priority', child: Text('Sắp xếp: Ưu tiên')),
              const PopupMenuItem(value: 'sort_time', child: Text('Sắp xếp: Thời gian')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'filter_low', child: Text('Lọc: Ưu tiên thấp')),
              const PopupMenuItem(value: 'filter_medium', child: Text('Lọc: Ưu tiên trung bình')),
              const PopupMenuItem(value: 'filter_high', child: Text('Lọc: Ưu tiên cao')),
              const PopupMenuItem(value: 'filter_none', child: Text('Bỏ lọc')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'grid', child: Text('Hiển thị: Grid')),
              const PopupMenuItem(value: 'list', child: Text('Hiển thị: List')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm ghi chú',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _refreshNotes();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _refreshNotes();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có ghi chú nào'));
                } else {
                  final notes = _sortNotes(snapshot.data!);
                  return _isGridView
                      ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return NoteItem(
                        note: notes[index],
                        isGridView: _isGridView,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(notes[index].id!);
                          _refreshNotes();
                        },
                        onEdit: (updatedNote) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NoteForm(note: updatedNote)),
                          ).then((_) => _refreshNotes());
                        },
                      );
                    },
                  )
                      : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return NoteItem(
                        note: notes[index],
                        isGridView: _isGridView,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(notes[index].id!);
                          _refreshNotes();
                        },
                        onEdit: (updatedNote) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NoteForm(note: updatedNote)),
                          ).then((_) => _refreshNotes());
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteForm()),
          );
          if (newNote != null) {
            await NoteDatabaseHelper.instance.insertNote(newNote);
            _refreshNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
