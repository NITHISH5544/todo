import 'package:flutter/material.dart';
import 'package:todo/services/auth/auth_service.dart';
import 'package:todo/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  // craeting _note and _noteSErvice to prevent
  //creating new note instance every time builder is called
  //for every hot reload
  DataBaseNote? _note;
  late final NotesService _noteService;
  late final TextEditingController _textController;
//init
  @override
  void initState() {
    _noteService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _noteService.updateNote(
      note: note,
      text: text,
    );
  }

//if already a _textControllerListner is present this function removes it
//and again adds _textControllerListner
  void _setUptextControllerlistner() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DataBaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    //usually this will crash "AuthService.firebase().currentUser"
    //but since we are making sure that u can enter notes view
    //only if u have loged in this statment doesnt crash
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    final existingNotes = await _noteService.getNote(id: owner.id);
    if (existingNotes != null) {
      return existingNotes; // Return the existing note if found
    }

    return await _noteService.createNote(owner: owner);
  }

  // Future<DataBaseNote> createNewNote() async {
  //   final existingNote = _note;
  //   if (existingNote != null) {
  //     return existingNote;
  //   }

  //   final currentUser = AuthService.firebase().currentUser;
  //   if (currentUser == null) {
  //     throw Exception('No user is currently logged in.');
  //   }

  //   final email = currentUser.email!;
  //   final owner = await _noteService.getUser(email: email);

  //   return await _noteService.createNote(owner: owner);
  // }

  // Future<DataBaseNote> createNewNote() async {
  //   final existingNote = _note;
  //   if (existingNote != null) {
  //     return existingNote; // Return the existing note if available
  //   }

  //   final currentUser = AuthService.firebase().currentUser;
  //   if (currentUser == null) {
  //     throw Exception('No user is currently logged in.');
  //   }

  //   final email = currentUser.email!;
  //   final owner = await _noteService.getUser(email: email);
  //   if (owner == null) {
  //     throw Exception('User not found.');
  //   }

  //   // Check if a note already exists for this user
  //   final existingNotes = await _noteService.getNote(id: owner.id);
  //   if (existingNotes != null) {
  //     return existingNotes; // Return the existing note if found
  //   }

  //   // Create a new note if none exists
  //   return await _noteService.createNote(owner: owner);
  // }

  void _deleteNoteIfTextIsEmplty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(
        note: note,
        text: text,
      );
    }
  }

//dispose
  @override
  void dispose() {
    _deleteNoteIfTextIsEmplty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
        ),
        // body: FutureBuilder(
        //   future: createNewNote(),
        //   builder: (context, snapshot) {
        //     switch (snapshot.connectionState) {
        //       case ConnectionState.done:
        //         _note = snapshot.data as DataBaseNote;
        //         _setUptextControllerlistner();
        //         return TextField(
        //           controller: _textController,
        //           //this is how text field can sent messages to text controller saying my contents has changed
        //           keyboardType: TextInputType.multiline,
        //           maxLines: null,
        //           //if you want your textfiled to increase as you enter the lines
        //           decoration: const InputDecoration(
        //             hintText: 'Start typing your note...',
        //           ),
        //         );
        //       default:
        //         return const CircularProgressIndicator();
        //     }
        //   },
        // ),
        body: FutureBuilder<DataBaseNote>(
          future: createNewNote(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No note found.'));
            }

            // Safe to access snapshot.data
            _note = snapshot.data!;
            _setUptextControllerlistner();
            return TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Start typing your note...',
              ),
            );
          },
        ));
  }
}
