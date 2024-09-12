import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo/firebase_options.dart';

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
      home: const HomePage(),
      // home: const RegisterView(),
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
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.red,
        backgroundColor: Colors.teal,
        title: const Text("Home"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              print('........................');
              print(FirebaseAuth.instance.currentUser);
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                print('your Emial is Verified');
              } else {
                print('You need to Verify your Email');
              }
              return const Text('Done....');

            default:
              return const Text('Loading.....');
          }
        },
      ),
    );
  }
}
