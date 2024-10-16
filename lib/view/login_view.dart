import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:todo/constants/routes.dart';
import 'package:todo/utilities/show_error_dialog.dart';

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
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration:
                const InputDecoration(hintText: 'Please enter your Email here'),
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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);
                if (!context.mounted) return;
                // ignore: use_build_context_synchronously
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  //email is verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  //email is not verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'User-not-found') {
                  await showErrorDialog(
                    // ignore: use_build_context_synchronously
                    context,
                    'User-not-found',
                  );
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(
                    // ignore: use_build_context_synchronously
                    context,
                    'wrong-password',
                  );
                } else if (e.code == 'invalid-credential') {
                  await showErrorDialog(
                    // ignore: use_build_context_synchronously
                    context,
                    'invalid-credentials',
                  );
                } else {
                  await showErrorDialog(
                    // ignore: use_build_context_synchronously
                    context,
                    'ERROR: ${e.code}',
                  );
                }
              } catch (e) {
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text(
              'Login',
              selectionColor: Colors.teal,
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Not Registered yet?register here!'))
        ],
      ),
    );
  }
}
