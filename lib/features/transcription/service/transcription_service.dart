/// Result of transcribing a recording into notation.
class TranscriptionResult {
  const TranscriptionResult({this.alphaTex, this.musicXml, this.error});

  /// alphaTex string (renderable directly by the alphaTab viewer).
  final String? alphaTex;

  /// MusicXML (alternative interchange format).
  final String? musicXml;

  final String? error;

  bool get isSuccess => error == null && (alphaTex != null || musicXml != null);
}

/// Converts a recorded audio file into sheet music.
///
/// This is the single swap-point for the transcription backend. Concrete
/// implementations:
///   * [StubTranscriptionService] — placeholder until a backend is configured.
///   * (later) GeminiTranscriptionService — uploads audio to Gemini.
///   * (later) BasicPitchTranscriptionService — calls a hosted Basic Pitch
///     endpoint that returns MIDI/MusicXML (the accurate, recommended path).
abstract interface class TranscriptionService {
  Future<TranscriptionResult> transcribe(String audioFilePath);
}

/// Default implementation used until the user wires up a real backend / API
/// key. Keeps the UI flow intact and tells the user exactly what's missing.
class StubTranscriptionService implements TranscriptionService {
  const StubTranscriptionService();

  @override
  Future<TranscriptionResult> transcribe(String audioFilePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const TranscriptionResult(
      error: 'Transcription backend not configured yet. Add a Gemini API key '
          'or deploy the Basic Pitch service, then swap in the concrete '
          'TranscriptionService.',
    );
  }
}
