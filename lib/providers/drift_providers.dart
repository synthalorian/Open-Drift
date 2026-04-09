import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sound_tile.dart';

const _uuid = Uuid();

final defaultSounds = [
  SoundTile(id: 'rain', name: 'Rain', icon: '🌧️', assetPath: 'assets/audio/rain.mp3'),
  SoundTile(id: 'vinyl', name: 'Vinyl Crackle', icon: '💿', assetPath: 'assets/audio/vinyl.mp3'),
  SoundTile(id: 'tape_hiss', name: 'Tape Hiss', icon: '📼', assetPath: 'assets/audio/tape_hiss.mp3'),
  SoundTile(id: 'synth_drone', name: 'Synth Drone', icon: '🎹', assetPath: 'assets/audio/synth_drone.mp3'),
  SoundTile(id: 'thunder', name: 'Thunder', icon: '⛈️', assetPath: 'assets/audio/thunder.mp3'),
  SoundTile(id: 'wind', name: 'Wind', icon: '💨', assetPath: 'assets/audio/wind.mp3'),
  SoundTile(id: 'fireplace', name: 'Fireplace', icon: '🔥', assetPath: 'assets/audio/fireplace.mp3'),
  SoundTile(id: 'cafe', name: 'Café', icon: '☕', assetPath: 'assets/audio/cafe.mp3'),
  SoundTile(id: 'ocean', name: 'Ocean Waves', icon: '🌊', assetPath: 'assets/audio/ocean.mp3'),
  SoundTile(id: 'forest', name: 'Forest', icon: '🌲', assetPath: 'assets/audio/forest.mp3'),
  SoundTile(id: 'night', name: 'Night Crickets', icon: '🦗', assetPath: 'assets/audio/night.mp3'),
  SoundTile(id: 'keyboard', name: 'Typing', icon: '⌨️', assetPath: 'assets/audio/keyboard.mp3'),
];

class SoundState {
  final List<SoundTile> sounds;
  final double masterVolume;
  final TimerDuration? activeTimer;
  final Duration? timeRemaining;

  const SoundState({
    required this.sounds,
    this.masterVolume = 0.8,
    this.activeTimer,
    this.timeRemaining,
  });

  SoundState copyWith({
    List<SoundTile>? sounds,
    double? masterVolume,
    TimerDuration? activeTimer,
    Duration? timeRemaining,
    bool clearTimer = false,
  }) {
    return SoundState(
      sounds: sounds ?? this.sounds,
      masterVolume: masterVolume ?? this.masterVolume,
      activeTimer: clearTimer ? null : (activeTimer ?? this.activeTimer),
      timeRemaining: clearTimer ? null : (timeRemaining ?? this.timeRemaining),
    );
  }

  List<SoundTile> get activeSounds => sounds.where((s) => s.isActive).toList();
}

class SoundNotifier extends StateNotifier<SoundState> {
  Timer? _timer;

  SoundNotifier()
      : super(SoundState(
          sounds: defaultSounds.map((s) => SoundTile(
            id: s.id,
            name: s.name,
            icon: s.icon,
            assetPath: s.assetPath,
          )).toList(),
        ));

  void toggleSound(String id) {
    final updated = state.sounds.map((s) {
      if (s.id == id) return s.copyWith(isActive: !s.isActive);
      return s;
    }).toList();
    state = state.copyWith(sounds: updated);
  }

  void setSoundVolume(String id, double volume) {
    final updated = state.sounds.map((s) {
      if (s.id == id) return s.copyWith(volume: volume);
      return s;
    }).toList();
    state = state.copyWith(sounds: updated);
  }

  void setMasterVolume(double volume) {
    state = state.copyWith(masterVolume: volume);
  }

  void startTimer(TimerDuration duration) {
    _timer?.cancel();
    if (duration == TimerDuration.infinite) {
      state = state.copyWith(activeTimer: duration, clearTimer: false);
      return;
    }
    state = state.copyWith(
      activeTimer: duration,
      timeRemaining: duration.duration,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.timeRemaining;
      if (remaining == null || remaining.inSeconds <= 0) {
        stopAll();
        return;
      }
      state = state.copyWith(
        timeRemaining: remaining - const Duration(seconds: 1),
      );
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    state = state.copyWith(clearTimer: true);
  }

  void stopAll() {
    _timer?.cancel();
    final updated = state.sounds.map((s) => s.copyWith(isActive: false)).toList();
    state = state.copyWith(sounds: updated, clearTimer: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final soundProvider = StateNotifierProvider<SoundNotifier, SoundState>((ref) {
  return SoundNotifier();
});

class MixStorageNotifier extends StateNotifier<List<AmbientMix>> {
  final Box _box;

  MixStorageNotifier(this._box) : super([]) {
    _load();
  }

  void _load() {
    final raw = _box.get('mixes', defaultValue: '[]') as String;
    final list = (jsonDecode(raw) as List)
        .map((e) => AmbientMix.fromJson(e as Map<String, dynamic>))
        .toList();
    state = list;
  }

  void _save() {
    _box.put('mixes', jsonEncode(state.map((m) => m.toJson()).toList()));
  }

  void saveMix(String name, List<SoundTile> activeSounds) {
    final mix = AmbientMix(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      activeSounds: {
        for (final s in activeSounds) s.id: s.volume,
      },
    );
    state = [...state, mix];
    _save();
  }

  void deleteMix(String id) {
    state = state.where((m) => m.id != id).toList();
    _save();
  }
}

final mixBoxProvider = FutureProvider<Box>((ref) async {
  return await Hive.openBox('open_drift_mixes');
});

final mixStorageProvider =
    StateNotifierProvider<MixStorageNotifier, List<AmbientMix>>((ref) {
  final boxAsync = ref.watch(mixBoxProvider);
  return boxAsync.when(
    data: (box) => MixStorageNotifier(box),
    loading: () => MixStorageNotifier(Hive.box('open_drift_mixes')),
    error: (_, __) => MixStorageNotifier(Hive.box('open_drift_mixes')),
  );
});
