import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_drift/providers/audio_provider.dart';
import 'package:open_drift/models/sound_tile.dart';
import 'package:open_drift/services/audio_service.dart';

class MockAudioService implements AudioService {
  @override
  double masterVolume = 0.8;

  final Set<String> activeSounds = {};
  final Map<String, double> volumes = {};
  bool disposed = false;

  @override
  Future<void> toggleSound(String soundId, String assetPath, bool active, double volume) async {
    if (active) {
      activeSounds.add(soundId);
      volumes[soundId] = volume;
    } else {
      activeSounds.remove(soundId);
    }
  }

  @override
  Future<void> startSound(String soundId, String assetPath, double volume) async {
    activeSounds.add(soundId);
    volumes[soundId] = volume;
  }

  @override
  Future<void> stopSound(String soundId) async {
    activeSounds.remove(soundId);
  }

  @override
  void setVolume(String soundId, double volume) {
    volumes[soundId] = volume;
  }

  @override
  Future<void> stopAll() async {
    activeSounds.clear();
  }

  @override
  bool isPlaying(String soundId) => activeSounds.contains(soundId);

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  group('SoundState', () {
    test('defaults to inactive with 0.7 volume', () {
      const state = SoundState(soundId: 'rain');
      expect(state.isActive, false);
      expect(state.volume, 0.7);
    });

    test('copyWith modifies specified fields', () {
      const state = SoundState(soundId: 'rain');
      final active = state.copyWith(isActive: true);
      expect(active.isActive, true);
      expect(active.volume, 0.7);
      expect(active.soundId, 'rain');

      final volumed = state.copyWith(volume: 0.3);
      expect(volumed.volume, 0.3);
      expect(volumed.isActive, false);
    });
  });

  group('TimerDuration', () {
    test('infinite has null duration', () {
      expect(TimerDuration.infinite.duration, isNull);
    });

    test('has correct durations', () {
      expect(TimerDuration.fifteen.duration, const Duration(minutes: 15));
      expect(TimerDuration.thirty.duration, const Duration(minutes: 30));
      expect(TimerDuration.sixty.duration, const Duration(minutes: 60));
      expect(TimerDuration.twoHours.duration, const Duration(hours: 2));
    });

    test('has correct labels', () {
      expect(TimerDuration.infinite.label, 'Infinite');
      expect(TimerDuration.fifteen.label, '15m');
      expect(TimerDuration.thirty.label, '30m');
      expect(TimerDuration.sixty.label, '1h');
      expect(TimerDuration.twoHours.label, '2h');
    });
  });

  group('AudioState', () {
    test('defaults are correct', () {
      const state = AudioState();
      expect(state.masterVolume, 0.8);
      expect(state.timerDuration, TimerDuration.infinite);
      expect(state.timerRemaining, isNull);
      expect(state.timerActive, false);
      expect(state.activeSoundCount, 0);
    });

    test('activeSoundCount reflects active sounds', () {
      final state = AudioState(
        sounds: {
          'rain': const SoundState(soundId: 'rain', isActive: true),
          'wind': const SoundState(soundId: 'wind', isActive: false),
          'thunder':
              const SoundState(soundId: 'thunder', isActive: true),
        },
      );
      expect(state.activeSoundCount, 2);
    });

    test('activeSoundIds returns correct IDs', () {
      final state = AudioState(
        sounds: {
          'rain': const SoundState(soundId: 'rain', isActive: true),
          'wind': const SoundState(soundId: 'wind', isActive: false),
          'thunder':
              const SoundState(soundId: 'thunder', isActive: true),
        },
      );
      expect(state.activeSoundIds, containsAll(['rain', 'thunder']));
      expect(state.activeSoundIds.length, 2);
    });

    test('activeVolumes returns volumes for active sounds', () {
      final state = AudioState(
        sounds: {
          'rain': const SoundState(
              soundId: 'rain', isActive: true, volume: 0.8),
          'wind': const SoundState(
              soundId: 'wind', isActive: false, volume: 0.5),
        },
      );
      expect(state.activeVolumes, {'rain': 0.8});
    });

    test('copyWith with clearTimer resets timer', () {
      final state = AudioState(
        timerRemaining: const Duration(minutes: 10),
        timerActive: true,
      );
      final cleared = state.copyWith(clearTimer: true, timerActive: false);
      expect(cleared.timerRemaining, isNull);
      expect(cleared.timerActive, false);
    });
  });

  group('AudioNotifier', () {
    late ProviderContainer container;
    late MockAudioService mockAudio;

    setUp(() {
      mockAudio = MockAudioService();
      container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with all sounds inactive', () {
      final state = container.read(audioProvider);
      expect(state.sounds.length, SoundTile.allSounds.length);
      for (final sound in state.sounds.values) {
        expect(sound.isActive, false);
        expect(sound.volume, 0.7);
      }
    });

    test('toggleSound activates a sound', () {
      container.read(audioProvider.notifier).toggleSound('rain');
      final state = container.read(audioProvider);
      expect(state.sounds['rain']?.isActive, true);
    });

    test('toggleSound deactivates an active sound', () {
      container.read(audioProvider.notifier).toggleSound('rain');
      container.read(audioProvider.notifier).toggleSound('rain');
      final state = container.read(audioProvider);
      expect(state.sounds['rain']?.isActive, false);
    });

    test('setSoundVolume updates volume', () {
      container.read(audioProvider.notifier).setSoundVolume('rain', 0.3);
      final state = container.read(audioProvider);
      expect(state.sounds['rain']?.volume, 0.3);
    });

    test('setMasterVolume updates master volume', () {
      container.read(audioProvider.notifier).setMasterVolume(0.5);
      final state = container.read(audioProvider);
      expect(state.masterVolume, 0.5);
    });

    test('setTimerDuration updates timer', () {
      container
          .read(audioProvider.notifier)
          .setTimerDuration(TimerDuration.thirty);
      final state = container.read(audioProvider);
      expect(state.timerDuration, TimerDuration.thirty);
    });

    test('loadMix activates specified sounds', () {
      container.read(audioProvider.notifier).loadMix({
        'rain': 0.9,
        'thunder': 0.4,
      });
      final state = container.read(audioProvider);
      expect(state.sounds['rain']?.isActive, true);
      expect(state.sounds['rain']?.volume, 0.9);
      expect(state.sounds['thunder']?.isActive, true);
      expect(state.sounds['thunder']?.volume, 0.4);
      expect(state.sounds['wind']?.isActive, false);
    });
  });
}
