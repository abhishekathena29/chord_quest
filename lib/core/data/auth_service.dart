import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper over [FirebaseAuth] (email + password) that turns Firebase
/// error codes into messages fit to show the player.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signIn({required String email, required String password}) =>
      _guard(() async {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        return cred.user!;
      });

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    return user;
  });

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> signOut() => _auth.signOut();

  /// Firebase only lets an account be deleted shortly after signing in, so
  /// the player confirms their password first.
  Future<void> reauthenticate(String password) => _guard(() async {
    final user = _auth.currentUser!;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
  });

  Future<void> deleteCurrentUser() =>
      _guard(() => _auth.currentUser!.delete());

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    }
  }

  static String _messageFor(String code) => switch (code) {
    'invalid-email' => 'That email address looks invalid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Choose a password with at least 6 characters.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'network-request-failed' => 'No internet connection. Please try again.',
    'requires-recent-login' => 'Please sign in again to continue.',
    _ => 'Something went wrong ($code). Please try again.',
  };
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
