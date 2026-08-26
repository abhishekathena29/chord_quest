// Basic smoke test for the ChordQuest app.

import 'package:flutter_test/flutter_test.dart';

import 'package:chord_quest/app.dart';

void main() {
  testWidgets('App boots to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const ChordQuestApp());
    await tester.pump();

    // The onboarding flow starts with a Skip affordance.
    expect(find.text('Skip'), findsOneWidget);
  });
}
