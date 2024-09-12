import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
        title: const Text("Register"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // TODO: Handle this case.
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
                      try {
                        final usercredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: email, password: password);
                        print(usercredential);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print('weak password ');
                        } else if (e.code == 'email-already-in-use') {
                          print('email is alredy in use ');
                        } else if (e.code == 'invalid-email') {
                          print('invalid email ');
                        }
                      }
                    },
                    child: const Text(
                      'Register',
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
