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
  String _sortBy = 'priority'; // Sắp xếp theo ưu tiên hoặc thời gian

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'grid') {
                  _isGridView = true;
                } else if (value == 'list') {
                  _isGridView = false;
                } else if (value == 'priority') {
                  _sortBy = 'priority';
                } else if (value == 'time') {
                  _sortBy = 'time';
                } else if (value == 'filter_low') {
                  _filterPriority = 1;
                } else if (value == 'filter_medium') {
                  _filterPriority = 2;
                } else if (value == 'filter_high') {
                  _filterPriority = 3;
                } else if (value == 'filter_none') {
                  _filterPriority = null;
                }
                _refreshNotes();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'grid', child: Text('Chế độ Grid')),
              const PopupMenuItem(value: 'list', child: Text('Chế độ List')),
              const PopupMenuItem(value: 'priority', child: Text('Sắp xếp theo ưu tiên')),
              const PopupMenuItem(value: 'time', child: Text('Sắp xếp theo thời gian')),
              const PopupMenuItem(value: 'filter_low', child: Text('Lọc: Ưu tiên thấp')),
              const PopupMenuItem(value: 'filter_medium', child: Text('Lọc: Ưu tiên trung bình')),
              const PopupMenuItem(value: 'filter_high', child: Text('Lọc: Ưu tiên cao')),
              const PopupMenuItem(value: 'filter_none', child: Text('Bỏ lọc')),
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
                prefixIcon: Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _refreshNotes();
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _refreshNotes();
                });
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
                      final note = notes[index];
                      return NoteItem(
                        note: note,
                        isGridView: _isGridView,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(note.id!);
                          _refreshNotes();
                        },
                        onEdit: (updatedNote) async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteForm(note: updatedNote),
                            ),
                          ).then((result) {
                            if (result != null) {
                              _refreshNotes();
                            }
                          });
                        },
                        onToggleComplete: (note) async {
                          final updatedNote = note.copyWith(isCompleted: !note.isCompleted);
                          await NoteDatabaseHelper.instance.updateNote(updatedNote);
                          _refreshNotes();
                        },
                      );
                    },
                  )
                      : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteItem(
                        note: note,
                        isGridView: _isGridView,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(note.id!);
                          _refreshNotes();
                        },
                        onEdit: (updatedNote) async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteForm(note: updatedNote),
                            ),
                          ).then((result) {
                            if (result != null) {
                              _refreshNotes();
                            }
                          });
                        },
                        onToggleComplete: (note) async {
                          final updatedNote = note.copyWith(isCompleted: !note.isCompleted);
                          await NoteDatabaseHelper.instance.updateNote(updatedNote);
                          _refreshNotes();
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
        child: const Icon(Icons.add),
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteForm()),
          );
          if (newNote != null) {
            await NoteDatabaseHelper.instance.insertNote(newNote);
            _refreshNotes();
          }
        },
      ),
    );
  }
}