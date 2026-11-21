import 'package:chord_quest/features/practice/ui/song_picker.dart';
import 'package:chord_quest/features/sheet_music/provider/sheet_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('song picker fits and scrolls on a small phone', (tester) async {
    // iPhone SE (1st gen) logical size: the smallest screen we support.
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => pickSongToPractice(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // A RenderFlex overflow would surface here as a test exception.
    expect(tester.takeException(), isNull);
    expect(find.text('Practice a song'), findsOneWidget);

    // Every song is reachable by scrolling the sheet.
    final last = SheetLibraryProvider().allSongs.last.title;
    await tester.scrollUntilVisible(find.text(last), 50);
    expect(find.text(last), findsOneWidget);
  });
}
