import 'package:flutter/material.dart';

enum AuthMode { signIn, signUp }

/// Manages the auth form: mode toggle, field values, obscure-password state and
/// a mock async submit. This is UI-only scaffolding — swap [submit]'s body for a
/// real backend call later.
class AuthProvider extends ChangeNotifier {
  AuthMode _mode = AuthMode.signIn;
  AuthMode get mode => _mode;

  bool get isSignIn => _mode == AuthMode.signIn;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _loading = false;
  bool get loading => _loading;

  void toggleMode() {
    _mode = isSignIn ? AuthMode.signUp : AuthMode.signIn;
    notifyListeners();
  }

  void toggleObscure() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Simulates authentication. Returns true on "success".
  Future<bool> submit() async {
    _loading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _loading = false;
    notifyListeners();
    return true;
  }
}
