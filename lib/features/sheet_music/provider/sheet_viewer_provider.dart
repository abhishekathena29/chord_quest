import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'sheet_library_provider.dart';

/// Owns the alphaTab WebView for one [SheetSong]: loads the renderer, injects
/// the score and relays playback controls / state.
class SheetViewerProvider extends ChangeNotifier {
  SheetViewerProvider({required this.song}) {
    _init();
  }

  final SheetSong song;

  late final WebViewController controller;

  bool _rendering = true;
  bool get rendering => _rendering;

  bool _playerReady = false;
  bool get playerReady => _playerReady;

  bool _playing = false;
  bool get playing => _playing;

  double _speed = 1.0;
  double get speed => _speed;

  bool _metronome = false;
  bool get metronome => _metronome;

  String? _error;
  String? get error => _error;

  void _init() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('AlphaTab', onMessageReceived: _onMessage)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => _loadScore()),
      )
      ..loadFlutterAsset('assets/alphatab/index.html');
  }

  void _loadScore() {
    // JSON-encode so any quotes/newlines in the tex are safely escaped.
    final tex = jsonEncode(song.tex);
    controller.runJavaScript('loadAlphaTex($tex);');
  }

  void _onMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      switch (data['type']) {
        case 'renderFinished':
          _rendering = false;
          _error = null;
          notifyListeners();
        case 'playerReady':
          _playerReady = true;
          notifyListeners();
        case 'playerState':
          _playing = (data['payload']?['playing'] as bool?) ?? false;
          notifyListeners();
        case 'error':
          _error = (data['payload']?['message'] as String?) ?? 'Render error';
          _rendering = false;
          notifyListeners();
      }
    } catch (_) {
      // Ignore malformed bridge messages.
    }
  }

  void togglePlay() => controller.runJavaScript('playPause();');

  void stop() => controller.runJavaScript('stop();');

  void setSpeed(double value) {
    _speed = value;
    controller.runJavaScript('setSpeed($value);');
    notifyListeners();
  }

  void toggleMetronome() {
    _metronome = !_metronome;
    controller.runJavaScript('setMetronome(${_metronome ? 'true' : 'false'});');
    notifyListeners();
  }
}
