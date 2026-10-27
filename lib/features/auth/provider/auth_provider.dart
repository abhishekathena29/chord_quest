import 'package:flutter/material.dart';

import '../../../core/data/auth_service.dart';
import '../../../core/session/user_session.dart';

enum AuthMode { signIn, signUp }

/// Manages the auth form: mode toggle, field controllers, obscure-password
/// state, validation and the Firebase submit. On success the root auth gate
/// reacts to the new session, so this provider never navigates.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._session);

  final UserSession _session;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  AuthMode get mode => _mode;

  bool get isSignIn => _mode == AuthMode.signIn;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  void toggleMode() {
    _mode = isSignIn ? AuthMode.signUp : AuthMode.signIn;
    _error = null;
    notifyListeners();
  }

  void toggleObscure() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? _validate() {
    final email = emailController.text.trim();
    if (!isSignIn && nameController.text.trim().isEmpty) {
      return 'Please enter your name.';
    }
    if (email.isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address.';
    }
    if (passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  Future<void> submit() async {
    _error = _validate();
    if (_error != null) {
      notifyListeners();
      return;
    }
    await _run(() async {
      if (isSignIn) {
        await _session.signIn(emailController.text, passwordController.text);
      } else {
        await _session.signUp(
          nameController.text,
          emailController.text,
          passwordController.text,
        );
      }
    });
  }

  /// Returns true when the reset email was sent.
  Future<bool> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _error = 'Enter your email above, then tap "Forgot password?".';
      notifyListeners();
      return false;
    }
    return _run(() => _session.sendPasswordReset(email));
  }

  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _loading = false;
      // The screen may already be gone if sign-in swapped the root widget.
      if (!_disposed) notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
