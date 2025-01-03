import 'package:flutter/material.dart';
import 'package:todo/services/cloud/cloud_note.dart';
// import 'package:sqflite/sqflite.dart';
//import 'package:todo/services/crud/notes_service.dart';
import 'package:todo/utilities/dialgos/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        //final note = allNotes[index];
        final note = notes.elementAt(index);

        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text, //change
            //"tillu new test",
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
