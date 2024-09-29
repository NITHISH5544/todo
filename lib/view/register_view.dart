import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/constants/routes.dart';
import 'package:todo/utilities/show_error_dialog.dart';

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
        title: const Text('Register'),
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
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  if (!context.mounted) return;

                  await showErrorDialog(
                    context,
                    'weak-password',
                  );
                } else if (e.code == 'email-already-in-use') {
                  if (!context.mounted) return;
                  await showErrorDialog(
                    context,
                    'email is alredy in use ',
                  );
                } else if (e.code == 'invalid-email') {
                  if (!context.mounted) return;
                  await showErrorDialog(
                    context,
                    'invalid email ',
                  );
                } else {
                  if (!context.mounted) return;
                  await showErrorDialog(
                    context,
                    'ERROR: ${e.code}',
                  );
                }
              } catch (e) {
                if (!context.mounted) return;

                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text(
              'Register',
              selectionColor: Colors.teal,
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('already Registered? Login here'))
        ],
      ),
    );
  }
}
