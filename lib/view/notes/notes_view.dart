//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/constants/routes.dart';
import 'package:todo/enums/menu_action.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:todo/services/auth/auth_service.dart';
import 'package:todo/services/auth/bloc/auth_bloc.dart';
import 'package:todo/services/auth/bloc/auth_event.dart';
import 'package:todo/services/cloud/cloud_note.dart';
import 'package:todo/services/cloud/firebase_cloud_storage.dart';
//import 'package:todo/services/crud/notes_service.dart';
//import 'dart:developer' as logger;

import 'package:todo/utilities/dialgos/logout_dialog.dart';
import 'package:todo/view/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Notes'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      // ignore: use_build_context_synchronously
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                      // ignore: use_build_context_synchronously
                      // Navigator.of(context).pushNamedAndRemoveUntil(
                      //   loginRoute,
                      //   (_) => false,
                      // );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log out'),
                  ),
                ];
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
