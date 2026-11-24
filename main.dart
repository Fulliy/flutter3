
import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class Note {
  final int id;
  String text;
  bool isImportant;

  Note({
    required this.id,
    required this.text,
    this.isImportant = false,
  });
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Заметки',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller =
      TextEditingController();

  final List<Note> _notes = [];

  int _nextId = 0;
  int? _editingId;

  void _saveNote() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите текст заметки!'),
        ),
      );
      return;
    }

    setState(() {
      if (_editingId == null) {
        _notes.add(
          Note(
            id: _nextId++,
            text: text,
          ),
        );
      } else {
        final index = _notes.indexWhere(
          (note) => note.id == _editingId,
        );

        if (index != -1) {
          _notes[index].text = text;
        }
      }

      _controller.clear();
      _editingId = null;
    });

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _viewNote(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Просмотр заметки'),
          content: SingleChildScrollView(
            child: Text(note.text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _makeImportant(Note note) {
    setState(() {
      note.isImportant = true;
    });
  }

  void _editNote(Note note) {
    setState(() {
      _controller.text = note.text;
      _editingId = note.id;
    });
  }

  void _deleteNoteById(int id) {
    setState(() {
      _notes.removeWhere((note) => note.id == id);

      if (_editingId == id) {
        _controller.clear();
        _editingId = null;
      }
    });
  }

  void _makeNormal(Note note) {
    setState(() {
      note.isImportant = false;
    });
  }

  void _toggleImportant(Note note) {
    setState(() {
      note.isImportant = !note.isImportant;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Введите заметку',
                hintText: 'Напишите что-нибудь...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveNote,
                icon: Icon(
                  _editingId == null
                      ? Icons.save
                      : Icons.edit,
                ),
                label: Text(
                  _editingId == null
                      ? 'Сохранить'
                      : 'Сохранить изменения',
                ),
              ),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Список заметок (${_notes.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: Text(
                        'Пока нет заметок',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];

                        return Dismissible(
                          key: ValueKey(note.id),

                          direction:
                              DismissDirection.horizontal,

                          confirmDismiss: (direction) async {
                            if (direction ==
                                DismissDirection.startToEnd) {
                              _makeNormal(note);
                              return false;
                            }

                            return true;
                          },

                          onDismissed: (direction) {
                            _deleteNoteById(note.id);
                          },

                          background: Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            alignment: Alignment.centerLeft,
                            color: Colors.green,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),

                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding: const EdgeInsets.only(
                              right: 20,
                            ),
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          child: GestureDetector(
                            onTap: () {
                              _viewNote(note);
                            },

                            onDoubleTap: () {
                              _makeImportant(note);
                            },

                            onLongPress: () {
                              _editNote(note);
                            },

                            child: Card(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),

                              color: note.isImportant
                                  ? Colors.yellow.shade100
                                  : null,

                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                ),

                                title: Text(
                                  note.text,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),

                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      tooltip: 'Важная заметка',
                                      icon: Icon(
                                        note.isImportant
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        _toggleImportant(note);
                                      },
                                    ),

                                    IconButton(
                                      tooltip: 'Редактировать',
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        _editNote(note);
                                      },
                                    ),

                                    IconButton(
                                      tooltip: 'Удалить',
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _deleteNoteById(note.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}