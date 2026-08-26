import 'dart:math' as math;

/// Pure music-theory helpers for converting between frequency, MIDI note
/// numbers, note names and cents. Shared by the tuner and practice scoring.
class NoteMath {
  NoteMath._();

  static const double a4 = 440.0;
  static const int a4Midi = 69;

  static const List<String> noteNames = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// Fractional MIDI number for a frequency (may be non-integer).
  static double midiFromFrequency(double frequency) {
    return a4Midi + 12 * (math.log(frequency / a4) / math.ln2);
  }

  /// Frequency in Hz for a (possibly fractional) MIDI number.
  static double frequencyFromMidi(num midi) {
    return a4 * math.pow(2, (midi - a4Midi) / 12);
  }

  /// Nearest integer MIDI note to a frequency.
  static int nearestMidi(double frequency) =>
      midiFromFrequency(frequency).round();

  /// Note name without octave, e.g. "A#".
  static String noteName(int midi) => noteNames[midi % 12];

  /// Scientific-pitch octave for a MIDI note (MIDI 60 == C4).
  static int octave(int midi) => (midi ~/ 12) - 1;

  /// Note name with octave, e.g. "E2".
  static String noteLabel(int midi) => '${noteName(midi)}${octave(midi)}';

  /// Signed deviation in cents of [frequency] from the nearest note.
  /// Positive => sharp, negative => flat. Range roughly -50..+50.
  static double centsFromNearest(double frequency) {
    final nearest = nearestMidi(frequency);
    final target = frequencyFromMidi(nearest);
    return 1200 * (math.log(frequency / target) / math.ln2);
  }

  /// Cents difference between [frequency] and a specific [targetMidi].
  static double centsFromTarget(double frequency, int targetMidi) {
    final target = frequencyFromMidi(targetMidi);
    return 1200 * (math.log(frequency / target) / math.ln2);
  }
}
