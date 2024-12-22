// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:todo/extensions/list/filter.dart';
// import 'package:todo/services/crud/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'dart:developer';

// class NotesService {
//   Database? _db;

//   List<DatabaseNote> _notes = [];
//   DatabaseUser? _user;

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//         // _notesStreamController.add(_notes);
//         //print("Current notes: $_notes");
//       },
//     );
//   }
//   factory NotesService() => _shared;

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }

//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     // Clear the existing notes
//     _notes.clear();

//     final allNotes = await getAllNotes();
//     //print("Fetched notes from database: $allNotes");
//     _notes.addAll(allNotes);
//     _notesStreamController.add(_notes);
//   }

// //maybe
//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // make sure note exists
//     await getNote(id: note.id);
//     log('note id: in update');
//     log((note.id).toString());
//     // update DB
//     log(text);
//     log(note.toString());

//     // final updatesCount = await db.update(noteTable, {
//     //   textColumn: text,
//     //   isSyncedWithCloudColumn: 0,
//     // });

//     final updatesCount = await db.update(
//       noteTable, // The table name
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn:
//             0, // Mark the note as not synced with the cloud
//       },
//       where: 'id = ?', // WHERE clause to match the note ID
//       whereArgs: [
//         note.id
//       ], // Provide the note ID as an argument to prevent SQL injection
//     );
//     //final updatesCount = 1;
//     if (updatesCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);

//       log('note id: after update');
//       log((note.id).toString());
//       // update DB
//       log(text);
//       log(note.toString());
//       log('_note : after update');
//       log(_notes.toString());
//       return updatedNote;
//     }
//   }

//   // Future<Iterable<DatabaseNote>> getAllNotes() async {
//   //   await _ensureDbIsOpen();
//   //   final db = _getDatabaseOrThrow();
//   //   final notes = await db.query(noteTable);

//   //   return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   // }
//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // Fetch notes from the database
//     final notes = await db.query(noteTable);
//     // print("Fetched raw notes from database: $notes");

//     // Map database rows to note objects
//     final mappedNotes = notes.map((noteRow) {
//       final note = DatabaseNote.fromRow(noteRow);
//       // print("Mapped note: $note");
//       return note;
//     });

//     return mappedNotes;
//   }

// //maybe
//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) {
//       throw CouldNotFindNote();
//     } else {
//       final note = DatabaseNote.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   // Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//   //   print("createNote called with owner: $owner");

//   //   await _ensureDbIsOpen();
//   //   final db = _getDatabaseOrThrow();

//   //   // make sure owner exists in the database with the correct id
//   //   final dbUser = await getUser(email: owner.email);
//   //   print("Database user fetched: $dbUser");
//   //   if (dbUser != owner) {
//   //     throw CouldNotFindUser();
//   //   }

//   //   const text = '';
//   //   // create the note
//   //   final noteId = await db.insert(noteTable, {
//   //     userIdColumn: owner.id,
//   //     textColumn: text,
//   //     isSyncedWithCloudColumn: 1,
//   //   });
//   //   print("Inserted note with ID: $noteId");
//   //   final note = DatabaseNote(
//   //     id: noteId,
//   //     userId: owner.id,
//   //     text: text,
//   //     isSyncedWithCloud: true,
//   //   );

//   //   _notes.add(note);
//   //   print("New notes list: $_notes");
//   //   _notesStreamController.add(_notes);
//   //   print("Stream updated with notes: $_notes");

//   //   return note;
//   // }

//   // Future<DatabaseNote> createNote({
//   //   required DatabaseUser owner,
//   //   required String text,
//   // }) async {
//   //   print("createNote called with owner: $owner and text: $text");

//   //   await _ensureDbIsOpen();
//   //   final db = _getDatabaseOrThrow();

//   //   // Verify that the owner exists
//   //   final dbUser = await getUser(email: owner.email);
//   //   print("Database user fetched: $dbUser");
//   //   if (dbUser != owner) {
//   //     throw CouldNotFindUser();
//   //   }

//   //   // Insert the new note
//   //   final noteId = await db.insert(noteTable, {
//   //     userIdColumn: owner.id,
//   //     textColumn: text, // Set the user-provided text here
//   //     isSyncedWithCloudColumn: 0,
//   //   });
//   //   print("Inserted note with ID: $noteId and text: $text");

//   //   final note = DatabaseNote(
//   //     id: noteId,
//   //     userId: owner.id,
//   //     text: text,
//   //     isSyncedWithCloud: false,
//   //   );

//   //   _notes.add(note);
//   //   _notesStreamController.add(_notes);
//   //   print("Updated notes list: $_notes");

//   //   return note;
//   // }

//   //

//   //gemini

//   Future<DatabaseNote> createNote({
//     required DatabaseUser owner,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // Ensure the user exists
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) throw CouldNotFindUser();

//     // Insert a new note
//     final noteId = await db.insert(
//       noteTable,
//       {
//         userIdColumn: owner.id,
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       conflictAlgorithm: ConflictAlgorithm.ignore,
//     );
//     log('\n\n\ninserted string is\n\n\n');
//     log(text);
//     // Fetch the newly created note from the database
//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: false,
//     );
//     log('\n\n\ncreated string is\n\n\n');
//     log(text);
//     // Add the new note to the in-memory list
//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DataBaseAlreadyOpenException {
//       // empty
//     }
//   }

//   // Future<void> open() async {
//   //   if (_db != null) {
//   //     throw DataBaseAlreadyOpenException();
//   //   }
//   //   try {
//   //     final docsPath = await getApplicationDocumentsDirectory();
//   //     final dbPath = join(docsPath.path, dbName);
//   //     final db = await openDatabase(dbPath);
//   //     _db = db;
//   //     // create the user table
//   //     await db.execute(createUserTable);
//   //     // create note table
//   //     await db.execute(createNoteTable);
//   //     await _cacheNotes();
//   //   } on MissingPlatformDirectoryException {
//   //     throw UnableToGetDocumentDirectory();
//   //   }
//   // }
//   Future<void> open() async {
//     if (_db != null) {
//       throw DataBaseAlreadyOpenException();
//     }
//     try {
//       // Get the application documents directory
//       final docsPath = await getApplicationDocumentsDirectory();

//       // Construct the database file path
//       final dbPath = join(docsPath.path, dbName);

//       // Log the database file path
//       //print("Database path: $dbPath");

//       // Open the database
//       final db = await openDatabase(dbPath);
//       _db = db;

//       // Create the user table
//       await db.execute(createUserTable);

//       // Create the note table
//       await db.execute(createNoteTable);

//       // Cache existing notes
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'goku.db';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//         "id"	INTEGER NOT NULL,
//         "email"	TEXT NOT NULL UNIQUE,
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
