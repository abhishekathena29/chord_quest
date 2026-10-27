import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../data/models/practice_session.dart';
import '../data/models/song_progress.dart';
import '../data/models/user_profile.dart';
import '../data/user_repository.dart';

enum SessionStatus { loading, signedOut, needsSetup, ready }

/// App-wide signed-in state: follows Firebase Auth, streams the player's
/// Firestore documents, and exposes the account / progress actions the
/// screens call. Provided once above [MaterialApp].
class UserSession extends ChangeNotifier {
  UserSession({AuthService? auth, UserRepository? repository})
    : _auth = auth ?? AuthService(),
      _repo = repository ?? UserRepository() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final AuthService _auth;
  final UserRepository _repo;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<Map<String, SongProgress>>? _songSub;
  StreamSubscription<List<PracticeSession>>? _recentSub;

  bool _authResolved = false;
  User? _user;
  User? get user => _user;

  bool _profileLoaded = false;
  UserProfile? _profile;

  /// The player's profile, or `null` before it has loaded / been created.
  UserProfile? get profile => _profile;

  Map<String, SongProgress> _songProgress = const {};
  Map<String, SongProgress> get songProgress => _songProgress;

  List<PracticeSession> _recentSessions = const [];
  List<PracticeSession> get recentSessions => _recentSessions;

  /// Onboarding slides are shown once per launch while signed out.
  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;

  SessionStatus get status {
    if (!_authResolved) return SessionStatus.loading;
    if (_user == null) return SessionStatus.signedOut;
    if (!_profileLoaded) return SessionStatus.loading;
    if (_profile == null || !_profile!.profileComplete) {
      return SessionStatus.needsSetup;
    }
    return SessionStatus.ready;
  }

  void finishOnboarding() {
    _onboardingDone = true;
    notifyListeners();
  }

  void _onAuthChanged(User? user) {
    _authResolved = true;
    if (user?.uid != _user?.uid) {
      _cancelDataSubs();
      _profile = null;
      _profileLoaded = false;
      _songProgress = const {};
      _recentSessions = const [];
      if (user != null) _listenToData(user.uid);
    }
    _user = user;
    notifyListeners();
  }

  void _listenToData(String uid) {
    _profileSub = _repo.watchUser(uid).listen((profile) {
      _profile = profile;
      _profileLoaded = true;
      notifyListeners();
    }, onError: _onStreamError);
    _songSub = _repo.watchSongProgress(uid).listen((progress) {
      _songProgress = progress;
      notifyListeners();
    }, onError: _onStreamError);
    _recentSub = _repo.watchRecentSessions(uid).listen((sessions) {
      _recentSessions = sessions;
      notifyListeners();
    }, onError: _onStreamError);
  }

  void _onStreamError(Object error) {
    // Typically permission-denied right after sign-out/delete; the auth
    // listener resets state, so just stop the spinner if we're stuck on it.
    debugPrint('UserSession stream error: $error');
    if (!_profileLoaded) {
      _profileLoaded = true;
      notifyListeners();
    }
  }

  void _cancelDataSubs() {
    _profileSub?.cancel();
    _songSub?.cancel();
    _recentSub?.cancel();
    _profileSub = null;
    _songSub = null;
    _recentSub = null;
  }

  // --- Account actions (throw [AuthFailure] with a user-facing message) ---

  Future<void> signIn(String email, String password) =>
      _auth.signIn(email: email, password: password);

  Future<void> signUp(String name, String email, String password) async {
    final user = await _auth.signUp(
      name: name,
      email: email,
      password: password,
    );
    await _repo.createUser(
      uid: user.uid,
      displayName: name.trim(),
      email: user.email ?? email.trim(),
    );
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  Future<void> completeProfileSetup({
    String? skillLevel,
    String? experience,
    String? goal,
  }) {
    final user = _user!;
    return _repo.completeProfileSetup(
      uid: user.uid,
      documentExists: _profile != null,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      skillLevel: skillLevel,
      experience: experience,
      goal: goal,
    );
  }

  Future<void> signOut() => _auth.signOut();

  /// Re-checks the password, wipes the player's Firestore data, then deletes
  /// the Firebase Auth account.
  Future<void> deleteAccount(String password) async {
    final uid = _user!.uid;
    await _auth.reauthenticate(password);
    _cancelDataSubs();
    await _repo.deleteAllUserData(uid);
    await _auth.deleteCurrentUser();
  }

  // --- Progress ---

  /// Saves a finished practice take. The write is applied to the local cache
  /// immediately (so XP/streak update on screen) and synced in the
  /// background, which also covers being offline.
  void recordSession(PracticeSession session) {
    final profile = _profile;
    if (profile == null) return;
    _repo
        .recordSession(
          profile: profile,
          session: session,
          previous: _songProgress[session.songId],
        )
        .catchError((Object e) => debugPrint('recordSession failed: $e'));
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cancelDataSubs();
    super.dispose();
  }
}
