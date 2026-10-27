import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Run with `--dart-define=USE_FIREBASE_EMULATOR=true` (debug/profile only)
/// to talk to `firebase emulators:start` instead of the live project.
/// `FIREBASE_EMULATOR_HOST` overrides the host, e.g. your computer's LAN IP
/// for a physical phone. (FlutterFire rewrites `localhost`/`127.0.0.1` to
/// 10.0.2.2 on Android.)
const _useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
const _emulatorHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_useEmulator && !kReleaseMode) {
    // The Android emulator reaches the host machine via 10.0.2.2.
    final host = _emulatorHost.isNotEmpty
        ? _emulatorHost
        : defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
  runApp(const ChordQuestApp());
}
