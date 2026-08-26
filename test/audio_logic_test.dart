import 'package:flutter_test/flutter_test.dart';

import 'package:chord_quest/core/audio/alphatex_notes.dart';
import 'package:chord_quest/core/audio/note_math.dart';

void main() {
  group('NoteMath', () {
    test('A4 = 440Hz maps to MIDI 69 / A4', () {
      expect(NoteMath.nearestMidi(440), 69);
      expect(NoteMath.noteLabel(69), 'A4');
    });

    test('low E string 82.41Hz maps to E2', () {
      expect(NoteMath.noteLabel(NoteMath.nearestMidi(82.41)), 'E2');
    });

    test('cents deviation is ~0 at exact pitch, positive when sharp', () {
      expect(NoteMath.centsFromTarget(440, 69).abs() < 0.5, isTrue);
      expect(NoteMath.centsFromTarget(445, 69) > 0, isTrue);
    });
  });

  group('AlphaTexNotes', () {
    test('parses the C major scale into 16 single notes starting on C4', () {
      const tex = '\\title "C Major Scale"\n\\tempo 90\n.\n'
          ':8 3.5 0.4 2.4 3.4 0.3 2.3 0.2 1.2 |'
          ':8 1.2 0.2 2.3 0.3 3.4 2.4 0.4 3.5';
      final notes = AlphaTexNotes.parse(tex);

      expect(notes.length, 16);
      // 3rd fret on the A string (string 5, open A2=45) => C3 (MIDI 48).
      expect(notes.first, {48});
      expect(NoteMath.noteName(notes.first.first), 'C');
    });

    test('parses a power chord into a multi-note set', () {
      const tex = '.\n:4 (0.6 2.5 2.4)';
      final notes = AlphaTexNotes.parse(tex);
      expect(notes.length, 1);
      // E2(40), A2+2=47(B2)... open low E + A string 2nd + D string 2nd.
      expect(notes.first, {40, 47, 52});
    });

    test('ignores durations and bar lines', () {
      const tex = '.\n:16 1.6 | 2.6';
      final notes = AlphaTexNotes.parse(tex);
      expect(notes.length, 2);
      expect(notes[0], {41}); // E2 + 1
      expect(notes[1], {42}); // E2 + 2
    });
  });
}
