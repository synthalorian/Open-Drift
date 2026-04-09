import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_tile.dart';
import '../services/audio_service.dart';

/// State for a single sound channel.
class SoundState {
  final String soundId;
  final bool isActive;
  final double volume;

  const SoundState({
    required this.soundId,
    this.isActive = false,
    this.volume = 0.7,
  });

  SoundState copyWith({bool? isActive, double? volume}) {
    return SoundState(
      soundId: soundId,
      isActive: isActive ?? this.isActive,
      volume: volume ?? this.volume,
    );
  }
}

/// Timer duration options.
enum TimerDuration {
  infinite(null, 'Infinite'),
  fifteen(Duration(minutes: 15), '15m'),
  thirty(Duration(minutes: 30), '30m'),
  sixty(Duration(minutes: 60), '1h'),
  twoHours(Duration(hours: 2), '2h');

  final Duration? duration;
  final String label;
  const TimerDuration(this.duration, this.label);
}

/// Full audio state for the app.
class AudioState {
  final Map<String, SoundState> sounds;
  final double masterVolume;
  final TimerDuration timerDuration;
  final Duration? timerRemaining;
  final bool timerActive;

  const AudioState({
    this.sounds = const {},
    this.masterVolume = 0.8,
    this.timerDuration = TimerDuration.infinite,
    this.timerRemaining,
    this.timerActive = false,
  });

  AudioState copyWith({
    Map<String, SoundState>? sounds,
    double? masterVolume,
    TimerDuration? timerDuration,
    Duration? timerRemaining,
    bool? timerActive,
    bool clearTimer = false,
  }) {
    return AudioState(
      sounds: sounds ?? this.sounds,
      masterVolume: masterVolume ?? this.masterVolume,
      timerDuration: timerDuration ?? this.timerDuration,
      timerRemaining: clearTimer ? null : (timerRemaining ?? this.timerRemaining),
      timerActive: timerActive ?? this.timerActive,
    );
  }

  int get activeSoundCount => sounds.values.where((s) => s.isActive).length;

  List<String> get activeSoundIds =>
      sounds.entries.where((e) => e.value.isActive).map((e) => e.key).toList();

  Map<String, double> get activeVolumes => Map.fromEntries(
        sounds.entries
            .where((e) => e.value.isActive)
            .map((e) => MapEntry(e.key, e.value.volume)),
      );
}

/// Main audio state notifier.
class AudioNotifier extends StateNotifier<AudioState> {
  final AudioService _audioService;
  Timer? _timer;

  AudioNotifier(this._audioService) : super(const AudioState()) {
    // Initialize sound states for all available sounds
    final sounds = <String, SoundState>{};
    for (final tile in SoundTile.allSounds) {
      sounds[tile.id] = SoundState(soundId: tile.id);
    }
    state = AudioState(sounds: sounds);
  }

  void toggleSound(String soundId) {
    final current = state.sounds[soundId];
    if (current == null) return;

    final newActive = !current.isActive;
    final tile = SoundTile.allSounds.firstWhere((t) => t.id == soundId);

    _audioService.toggleSound(soundId, tile.assetPath, newActive, current.volume);

    final updatedSounds = Map<String, SoundState>.from(state.sounds);
    updatedSounds[soundId] = current.copyWith(isActive: newActive);
    state = state.copyWith(sounds: updatedSounds);
  }

  void setSoundVolume(String soundId, double volume) {
    final current = state.sounds[soundId];
    if (current == null) return;

    _audioService.setVolume(soundId, volume);

    final updatedSounds = Map<String, SoundState>.from(state.sounds);
    updatedSounds[soundId] = current.copyWith(volume: volume);
    state = state.copyWith(sounds: updatedSounds);
  }

  void setMasterVolume(double volume) {
    _audioService.masterVolume = volume;
    state = state.copyWith(masterVolume: volume);
  }

  void setTimerDuration(TimerDuration duration) {
    _cancelTimer();
    state = state.copyWith(
      timerDuration: duration,
      timerActive: false,
      clearTimer: true,
    );
  }

  void startTimer() {
    if (state.timerDuration == TimerDuration.infinite) return;
    final duration = state.timerDuration.duration;
    if (duration == null) return;

    _cancelTimer();
    state = state.copyWith(
      timerRemaining: duration,
      timerActive: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.timerRemaining;
      if (remaining == null || remaining.inSeconds <= 0) {
        _cancelTimer();
        _stopAllSounds();
        state = state.copyWith(timerActive: false, clearTimer: true);
        return;
      }
      state = state.copyWith(
        timerRemaining: remaining - const Duration(seconds: 1),
      );
    });
  }

  void stopTimer() {
    _cancelTimer();
    state = state.copyWith(timerActive: false, clearTimer: true);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _stopAllSounds() {
    _audioService.stopAll();
    final updatedSounds = state.sounds.map(
      (key, value) => MapEntry(key, value.copyWith(isActive: false)),
    );
    state = state.copyWith(sounds: updatedSounds);
  }

  /// Load a saved mix — activate sounds with specified volumes.
  void loadMix(Map<String, double> soundVolumes) {
    _audioService.stopAll();

    final updatedSounds = <String, SoundState>{};
    for (final tile in SoundTile.allSounds) {
      final volume = soundVolumes[tile.id];
      final isActive = volume != null;
      updatedSounds[tile.id] = SoundState(
        soundId: tile.id,
        isActive: isActive,
        volume: volume ?? 0.7,
      );
      if (isActive) {
        _audioService.startSound(tile.id, tile.assetPath, volume);
      }
    }
    state = state.copyWith(sounds: updatedSounds);
  }

  @override
  void dispose() {
    _cancelTimer();
    _audioService.dispose();
    super.dispose();
  }
}

/// Providers
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  final service = ref.watch(audioServiceProvider);
  return AudioNotifier(service);
});
