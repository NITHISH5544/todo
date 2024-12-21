import 'package:test/test.dart';
import 'package:todo/services/auth/auth_exceptions.dart';
import 'package:todo/services/auth/auth_provider.dart';
import 'package:todo/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initailized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('Uer should be null after initializion', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    // test('create user should delegate to login function', () async {
    //   final badEmailUser = await provider.createUser(
    //     email: 'food@bad.com',
    //     password: 'anypassword',
    //   );
    //   expect(badEmailUser,
    //       throwsA(const TypeMatcher<UserNotFoundAuthException>()));

    //   final badPasswordUser = provider.createUser(
    //     email: 'Some@bad.com',
    //     password: 'foobar',
    //   );
    //   expect(badPasswordUser,
    //       throwsA(const TypeMatcher<WrongPasswordAuthException>()));

    //   final user = await provider.createUser(
    //     email: 'foo',
    //     password: 'bar',
    //   );
    //   expect(provider.currentUser, user);
    //   expect(user.isEmailVerified, false);
    // });

    test('create user should delegate to login function', () async {
      // Test for a bad email
      expect(
        () async => await provider.createUser(
          email: 'food@bad.com',
          password: 'anypassword',
        ),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      // Test for a bad password
      expect(
        () async => await provider.createUser(
          email: 'Some@bad.com',
          password: 'foobar',
        ),
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      // Test for successful user creation
      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    // test('Logged in user should be able to get verified', () {
    //   provider.sendEmailVerification();
    //   final user = provider.currentUser;
    //   expect(user, isNotNull);
    //   expect(user!.isEmailVerified, true);
    // });

    test('Logged in user should be able to get verified', () async {
      // Log in a user
      await provider.logIn(
        email: 'foo',
        password: 'bar',
      );

      // Send email verification
      await provider.sendEmailVerification();

      // Check if the user is verified
      final user = provider.currentUser;
      expect(user, isNotNull); // Check that the user exists
      expect(
          user!.isEmailVerified, true); // Check that the user is now verified
    });

    test('Should be able to log out and log in again', () async {
      // Log in a user first
      await provider.logIn(
        email: 'foo',
        password: 'bar',
      );

      // Now log out the user
      await provider.logOut();

      // Log in again
      await provider.logIn(
        email: 'foo',
        password: 'bar',
      );

      // Verify the user is logged in
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements MyAuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // @override
  // Future<AuthUser> createUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   if (!isInitialized) throw NotInitializedException();
  //   await Future.delayed(const Duration(seconds: 1));
  //   return logIn(
  //     email: email,
  //     password: password,
  //   );
  // }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));

    // Check for a specific email and throw an exception
    if (email == 'food@bad.com') {
      throw UserNotFoundAuthException();
    }
    if (password == 'foobar') {
      throw WrongPasswordAuthException();
    }

    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'food@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'my_id',
      isEmailVerified: false,
      email: 'foo@bar.com',
    );

    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      id: 'my_id',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newUser;
  }
}
