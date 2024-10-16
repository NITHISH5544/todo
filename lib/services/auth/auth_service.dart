import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo/services/auth/auth_provider.dart';
import 'package:todo/services/auth/auth_user.dart';

class AuthService implements MyAuthProvider {
  final AuthProvider provider;

  AuthService({required this.provider});

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) {}

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => throw UnimplementedError();

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {}

  @override
  Future<void> logOut() {}

  @override
  Future<void> sendEmailVerification() {}
}
