import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return const Placeholder(
    //   color: Colors.teal,
    // );
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.red,
        backgroundColor: Colors.teal,
        title: const Text("login"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                        hintText: 'Please enter your Email here'),
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(
                        hintText: 'Please enter your Password here'),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      FirebaseAuth.instance
                          .signOut(); // NOTE: to remove cache of previous user credentials. of they exists
                      try {
                        final usercredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                        print(usercredential);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'User-not-found') {
                          print('User not found');
                        } else if (e.code == 'wront-password') {
                          print('Weak passsword');
                        }
                      }
                    },
                    child: const Text(
                      'Login',
                      selectionColor: Colors.teal,
                    ),
                  ),
                ],
              );
            default:
              return const Text('Loading.....');
          }
        },
      ),
    );
  }
}
