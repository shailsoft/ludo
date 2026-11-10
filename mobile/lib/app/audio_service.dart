import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'settings.dart';

class AudioService {
  AudioService._();
  static final instance = AudioService._();
  final _music = AudioPlayer();
  final _effects = AudioPlayer();
  final _files = <String, String>{};
  bool _ready = false;
  bool _musicPlaying = false;

  Future<void> initialize() async {
    if (_ready) return;
    final directory = await getTemporaryDirectory();
    for (final entry in <String, List<double>>{
      'roll': _tone(.10, (t) => 520 + 180 * sin(t * 70)),
      'move': _tone(.07, (t) => 700 + 100 * t),
      'capture': _tone(.22, (t) => 620 - 500 * t),
      'win': _tone(.9, (t) => [523.25, 659.25, 783.99][(t * 9).floor() % 3]),
      'music': _tone(
        4,
        (t) => [261.63, 329.63, 392.0, 329.63][(t * 2).floor() % 4],
        volume: .13,
      ),
    }.entries) {
      final file = File('${directory.path}/ludo_${entry.key}.wav');
      if (!await file.exists()) {
        await file.writeAsBytes(_wave(entry.value), flush: true);
      }
      _files[entry.key] = file.path;
    }
    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(.22);
    _ready = true;
  }

  Future<void> sync(AppSettings settings) async {
    if (!_ready) return;
    if (settings.music && !_musicPlaying) {
      _musicPlaying = true;
      await _music.play(DeviceFileSource(_files['music']!));
    } else if (!settings.music && _musicPlaying) {
      _musicPlaying = false;
      await _music.stop();
    }
  }

  Future<void> effect(String name, {required bool enabled}) async {
    if (!_ready || !enabled || !_files.containsKey(name)) return;
    await _effects.stop();
    await _effects.play(DeviceFileSource(_files[name]!));
  }

  static List<double> _tone(
    double seconds,
    double Function(double t) frequency, {
    double volume = .28,
  }) {
    const rate = 22050;
    var phase = 0.0;
    return List.generate((rate * seconds).round(), (i) {
      final t = i / rate;
      phase += 2 * pi * frequency(t) / rate;
      final envelope =
          min(1.0, i / 220) * min(1.0, ((rate * seconds) - i) / 440);
      return sin(phase) * volume * envelope;
    });
  }

  static Uint8List _wave(List<double> samples) {
    const rate = 22050;
    final dataSize = samples.length * 2;
    final bytes = ByteData(44 + dataSize);
    void text(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, rate, Endian.little);
    bytes.setUint32(28, rate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    text(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      bytes.setInt16(
        44 + i * 2,
        (samples[i] * 32767).round().clamp(-32768, 32767),
        Endian.little,
      );
    }
    return bytes.buffer.asUint8List();
  }
}
