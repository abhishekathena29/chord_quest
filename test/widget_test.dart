// Basic smoke test for the ChordQuest app.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chord_quest/app.dart';
import 'package:chord_quest/core/data/auth_service.dart';
import 'package:chord_quest/core/data/user_repository.dart';
import 'package:chord_quest/core/session/user_session.dart';

/// Signed-out auth with no Firebase behind it.
class _SignedOutAuth implements AuthService {
  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Signed-out app boots to onboarding', (tester) async {
    await tester.pumpWidget(
      ChordQuestApp(
        createSession: () => UserSession(
          auth: _SignedOutAuth(),
          repository: _UnusedRepository(),
        ),
      ),
    );
    // The background animates forever, so pump past the auth event and the
    // gate's cross-fade instead of waiting to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The onboarding flow starts with a Skip affordance.
    expect(find.text('Skip'), findsOneWidget);
  });
}
