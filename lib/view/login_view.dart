import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/constants/routes.dart';
import 'package:todo/services/auth/auth_exceptions.dart';
import 'package:todo/services/auth/auth_service.dart';
import 'package:todo/services/auth/bloc/auth_bloc.dart';
import 'package:todo/services/auth/bloc/auth_event.dart';
import 'package:todo/services/auth/bloc/auth_state.dart';
import 'package:todo/utilities/dialgos/error_dialod.dart';

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
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthStateLoggedOut) {
                if (state.exception is UserNotFoundAuthException) {
                  await showErrorDialog(context, 'Usernot found');
                } else if (state.exception is WrongPasswordAuthException) {
                  await showErrorDialog(context, 'wrong credentials');
                } else if (state.exception is GenericAuthException) {
                  await showErrorDialog(context, 'Authentiaction error');
                }
              }
            },
            child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                //AuthService.firebase().logOut();
                // NOTE: to remove cache of previous user credentials. of they exists
                context.read<AuthBloc>().add(
                      AuthEventLogIn(
                        email,
                        password,
                      ),
                    );
              },
              child: const Text(
                'Login',
                selectionColor: Colors.teal,
              ),
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
