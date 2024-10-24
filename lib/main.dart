import 'package:flutter/material.dart';
import 'package:todo/constants/routes.dart';
import 'package:todo/services/auth/auth_service.dart';
import 'package:todo/view/login_view.dart';
import 'package:todo/view/notes/new_note_view.dart';
import 'package:todo/view/notes/notes_view.dart';
import 'package:todo/view/register_view.dart';
import 'package:todo/view/verify_email_view.dart';
//import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // to make sure the pre reqired files are initialized first
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const LoginView(),
      //home: const RegisterView(),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        notesRoute: (context) => const NotesView(),
        newNoteroute: (context) => const NewNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // return const Placeholder(
    //   color: Colors.teal,
    // );
    return FutureBuilder(
      future: AuthService.firebase()
          .initialize(), // CHANGED FROM  FIREBASE .INITIALIZEAPP TO AuthService.firebase().initialize()
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase()
                .currentUser; // CHANGED FROM FIREBASE .CURRENTUSER TO AuthService.firebase().initialize()
            if (user != null) {
              if (user.isEmailVerified) {
                //// CHANGED FROM USER.EMAILVERIFIED TO user.isEmailVerified
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
