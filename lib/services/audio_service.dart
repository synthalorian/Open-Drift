import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Manages audio playback for ambient sounds.
/// Gracefully handles missing audio files — the UI remains fully functional
/// even without bundled assets.
class AudioService {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _targetVolumes = {};
  final Map<String, Timer?> _fadeTimers = {};
  double _masterVolume = 0.8;

  static const Duration _fadeDuration = Duration(milliseconds: 800);
  static const int _fadeSteps = 20;

  double get masterVolume => _masterVolume;

  set masterVolume(double value) {
    _masterVolume = value.clamp(0.0, 1.0);
    for (final entry in _targetVolumes.entries) {
      final player = _players[entry.key];
      if (player != null) {
        player.setVolume(entry.value * _masterVolume);
      }
    }
  }

  Future<AudioPlayer?> _getOrCreatePlayer(String soundId, String assetPath) async {
    if (_players.containsKey(soundId)) {
      return _players[soundId];
    }

    final player = AudioPlayer();
    try {
      await player.setAsset(assetPath);
      await player.setLoopMode(LoopMode.all);
      await player.setVolume(0);
      _players[soundId] = player;
      return player;
    } catch (e) {
      debugPrint('OpenDrift: Could not load audio asset "$assetPath": $e');
      await player.dispose();
      return null;
    }
  }

  Future<void> toggleSound(String soundId, String assetPath, bool active, double volume) async {
    if (active) {
      await startSound(soundId, assetPath, volume);
    } else {
      await stopSound(soundId);
    }
  }

  Future<void> startSound(String soundId, String assetPath, double volume) async {
    _targetVolumes[soundId] = volume;
    final player = await _getOrCreatePlayer(soundId, assetPath);
    if (player == null) return;

    await player.setVolume(0);
    await player.seek(Duration.zero);
    await player.play();
    _fadeIn(soundId, volume);
  }

  Future<void> stopSound(String soundId) async {
    final player = _players[soundId];
    if (player == null) return;

    _fadeOut(soundId, () async {
      await player.pause();
      await player.seek(Duration.zero);
      _targetVolumes.remove(soundId);
    });
  }

  void setVolume(String soundId, double volume) {
    _targetVolumes[soundId] = volume;
    final player = _players[soundId];
    if (player != null && (player.playing)) {
      player.setVolume(volume * _masterVolume);
    }
  }

  void _fadeIn(String soundId, double targetVolume) {
    _cancelFade(soundId);
    final player = _players[soundId];
    if (player == null) return;

    final stepDuration = Duration(
      milliseconds: _fadeDuration.inMilliseconds ~/ _fadeSteps,
    );
    int step = 0;

    _fadeTimers[soundId] = Timer.periodic(stepDuration, (timer) {
      step++;
      final progress = step / _fadeSteps;
      final currentVolume = targetVolume * progress * _masterVolume;
      player.setVolume(currentVolume.clamp(0.0, 1.0));

      if (step >= _fadeSteps) {
        timer.cancel();
        _fadeTimers[soundId] = null;
      }
    });
  }

  void _fadeOut(String soundId, VoidCallback onComplete) {
    _cancelFade(soundId);
    final player = _players[soundId];
    if (player == null) {
      onComplete();
      return;
    }

    final startVolume = player.volume;
    final stepDuration = Duration(
      milliseconds: _fadeDuration.inMilliseconds ~/ _fadeSteps,
    );
    int step = 0;

    _fadeTimers[soundId] = Timer.periodic(stepDuration, (timer) {
      step++;
      final progress = 1.0 - (step / _fadeSteps);
      player.setVolume((startVolume * progress).clamp(0.0, 1.0));

      if (step >= _fadeSteps) {
        timer.cancel();
        _fadeTimers[soundId] = null;
        onComplete();
      }
    });
  }

  void _cancelFade(String soundId) {
    _fadeTimers[soundId]?.cancel();
    _fadeTimers[soundId] = null;
  }

  bool isPlaying(String soundId) {
    return _players[soundId]?.playing ?? false;
  }

  Future<void> stopAll() async {
    for (final soundId in _players.keys.toList()) {
      await stopSound(soundId);
    }
  }

  Future<void> dispose() async {
    for (final timer in _fadeTimers.values) {
      timer?.cancel();
    }
    _fadeTimers.clear();
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _targetVolumes.clear();
  }
}
