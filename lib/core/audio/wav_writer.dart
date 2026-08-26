import 'dart:io';
import 'dart:typed_data';

/// Wraps accumulated raw PCM16 audio bytes in a canonical WAV container and
/// writes it to disk. Used to persist a practice recording captured from the
/// mic stream so it can later be transcribed.
class WavWriter {
  WavWriter({this.sampleRate = 44100, this.numChannels = 1});

  final int sampleRate;
  final int numChannels;

  final BytesBuilder _pcm = BytesBuilder(copy: false);

  void add(Uint8List pcm16Chunk) => _pcm.add(pcm16Chunk);

  int get byteLength => _pcm.length;
  Duration get duration => Duration(
        milliseconds:
            ((_pcm.length / 2) / (sampleRate * numChannels) * 1000).round(),
      );

  /// Serialises the buffered PCM to a `.wav` file at [path].
  Future<File> writeTo(String path) async {
    final data = _pcm.toBytes();
    final file = File(path);
    await file.writeAsBytes(_wrap(data), flush: true);
    return file;
  }

  Uint8List _wrap(Uint8List pcm) {
    const bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = pcm.length;
    final fileSize = 44 - 8 + dataSize;

    final header = BytesBuilder();
    void str(String s) => header.add(s.codeUnits);
    void u32(int v) {
      final b = ByteData(4)..setUint32(0, v, Endian.little);
      header.add(b.buffer.asUint8List());
    }

    void u16(int v) {
      final b = ByteData(2)..setUint16(0, v, Endian.little);
      header.add(b.buffer.asUint8List());
    }

    str('RIFF');
    u32(fileSize);
    str('WAVE');
    str('fmt ');
    u32(16); // PCM chunk size
    u16(1); // PCM format
    u16(numChannels);
    u32(sampleRate);
    u32(byteRate);
    u16(blockAlign);
    u16(bitsPerSample);
    str('data');
    u32(dataSize);

    return (header..add(pcm)).toBytes();
  }
}
