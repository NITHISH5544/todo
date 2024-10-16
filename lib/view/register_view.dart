import 'package:flutter/material.dart';
import 'package:todo/constants/routes.dart';
import 'package:todo/services/auth/auth_exceptions.dart';
import 'package:todo/services/auth/auth_service.dart';
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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerification();
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                if (!context.mounted) return;

                await showErrorDialog(
                  context,
                  'weak-password',
                );
              } on EmailAlreadyInUseAuthException {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  'email is alredy in use ',
                );
              } on InvalidEmailAuthException {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  'invalid email ',
                );
              } on GenericAuthException {
                if (!context.mounted) return;

                await showErrorDialog(
                  context,
                  'Failed To register',
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
