/// A minimal alphaTex reader that extracts the sequence of expected notes for
/// monophonic practice scoring. It is intentionally lenient — it understands
/// just enough (`fret.string` tokens, chords, bars, durations, metadata) to
/// turn the bundled exercises into a note timeline. It is NOT a full parser.
class AlphaTexNotes {
  AlphaTexNotes._();

  /// Open-string MIDI notes for standard tuning, indexed by alphaTex string
  /// number (1 = high E .. 6 = low E).
  static const Map<int, int> _openStringMidi = {
    1: 64, // E4
    2: 59, // B3
    3: 55, // G3
    4: 50, // D3
    5: 45, // A2
    6: 40, // E2
  };

  /// Returns a timeline where each entry is the set of MIDI notes acceptable at
  /// that step (a single note, or all notes of a chord).
  static List<Set<int>> parse(String tex) {
    // Drop the metadata header (everything up to and including the lone '.').
    final dotIndex = tex.indexOf(RegExp(r'^\s*\.\s*$', multiLine: true));
    final body = dotIndex >= 0 ? tex.substring(dotIndex + 1) : tex;

    final timeline = <Set<int>>[];
    // Tokenise on whitespace but keep parenthesised chords together.
    final tokens = _tokenize(body);

    for (final token in tokens) {
      if (token.startsWith(':') || token == '|' || token.isEmpty) {
        continue; // duration marker or bar line
      }
      if (token.startsWith('(')) {
        final inner = token.replaceAll(RegExp(r'[()]'), '');
        final notes = <int>{};
        for (final part in inner.split(RegExp(r'\s+'))) {
          final m = _noteFromToken(part);
          if (m != null) notes.add(m);
        }
        if (notes.isNotEmpty) timeline.add(notes);
      } else {
        final m = _noteFromToken(token);
        if (m != null) timeline.add({m});
      }
    }
    return timeline;
  }

  static List<String> _tokenize(String body) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    var inParens = false;
    for (var i = 0; i < body.length; i++) {
      final c = body[i];
      if (c == '(') {
        inParens = true;
        buffer.write(c);
      } else if (c == ')') {
        inParens = false;
        buffer.write(c);
        tokens.add(buffer.toString());
        buffer.clear();
      } else if (!inParens && (c == ' ' || c == '\n' || c == '\t' || c == '\r')) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
      } else {
        buffer.write(c);
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }

  /// Parses a `fret.string` token into a MIDI note, else null.
  static int? _noteFromToken(String token) {
    final match = RegExp(r'^(\d+)\.(\d+)$').firstMatch(token);
    if (match == null) return null;
    final fret = int.parse(match.group(1)!);
    final string = int.parse(match.group(2)!);
    final open = _openStringMidi[string];
    if (open == null) return null;
    return open + fret;
  }
}
