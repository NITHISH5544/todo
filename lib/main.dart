//import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/constants/routes.dart';
//import 'package:todo/services/auth/auth_service.dart';
import 'package:todo/services/auth/bloc/auth_bloc.dart';
import 'package:todo/services/auth/bloc/auth_event.dart';
import 'package:todo/services/auth/bloc/auth_state.dart';
import 'package:todo/services/auth/firebase_auth_provider.dart';
import 'package:todo/view/login_view.dart';
import 'package:todo/view/notes/create_update_note_view.dart';
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
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        notesRoute: (context) => const NotesView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsEmailVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
//     return FutureBuilder(
//       future: AuthService.firebase()
//           .initialize(), // CHANGED FROM  FIREBASE .INITIALIZEAPP TO AuthService.firebase().initialize()
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = AuthService.firebase()
//                 .currentUser; // CHANGED FROM FIREBASE .CURRENTUSER TO AuthService.firebase().initialize()
//             if (user != null) {
//               if (user.isEmailVerified) {
//                 //// CHANGED FROM USER.EMAILVERIFIED TO user.isEmailVerified
//                 return const NotesView();
//               } else {
//                 return const VerifyEmailView();
//               }
//             } else {
//               return const LoginView();
//             }

//           default:
//             return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }





//..............Counter bloc code............


// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBlock(),
//       child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Testing Bloc'),
//           ),
//           //BlockConsumer= BlockListner+BlockBuilder
//           body: BlocConsumer<CounterBlock, CounterState>(
//             builder: (context, state) {
//               final invalidValue = (state is CounterStateInvalidNumber)
//                   ? state.invalidValue
//                   : '';
//               return Column(
//                 children: [
//                   Text('Current value=> ${state.value}'),
//                   Visibility(
//                     visible: state is CounterStateInvalidNumber,
//                     child: Text('Invalid Input: $invalidValue'),
//                   ),
//                   TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter a Number here',
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           context
//                               .read<CounterBlock>()
//                               .add(DecrementEvent(_controller.text));
//                         },
//                         child: const Text('-'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           context
//                               .read<CounterBlock>()
//                               .add(IncrementEvent(_controller.text));
//                         },
//                         child: const Text('+'),
//                       ),
//                     ],
//                   )
//                 ],
//               );
//             },
//             listener: (context, state) {
//               _controller.clear();
//             },
//           )),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;
//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousvalue,
//   }) : super(previousvalue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;

//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBlock extends Bloc<CounterEvent, CounterState> {
//   CounterBlock() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>(
//       (event, emit) {
//         final integer = int.tryParse(event.value);
//         if (integer == null) {
//           emit(
//             CounterStateInvalidNumber(
//               invalidValue: event.value,
//               previousvalue: state.value,
//             ),
//           );
//         } else {
//           emit(CounterStateValid(state.value + integer));
//         }
//       },
//     );
//     on<DecrementEvent>(
//       (event, emit) {
//         final integer = int.tryParse(event.value);
//         if (integer == null) {
//           emit(
//             CounterStateInvalidNumber(
//               invalidValue: event.value,
//               previousvalue: state.value,
//             ),
//           );
//         } else {
//           emit(CounterStateValid(state.value - integer));
//         }
//       },
//     );
//   }
// }
