import 'package:flutter_test/flutter_test.dart';
import 'package:open_drift/models/sound_tile.dart';

void main() {
  group('SoundTile', () {
    test('copyWith creates new instance with updated fields', () {
      final tile = SoundTile(
        id: 'rain',
        name: 'Rain',
        icon: '🌧️',
        assetPath: 'assets/audio/rain.mp3',
      );

      final active = tile.copyWith(isActive: true, volume: 0.5);
      expect(active.isActive, true);
      expect(active.volume, 0.5);
      expect(active.id, 'rain');
      expect(tile.isActive, false); // original unchanged
    });

    test('JSON round-trip preserves data', () {
      final tile = SoundTile(
        id: 'test',
        name: 'Test',
        icon: '🔊',
        assetPath: 'assets/test.mp3',
        isActive: true,
        volume: 0.42,
      );

      final json = tile.toJson();
      final restored = SoundTile.fromJson(json);
      expect(restored.id, tile.id);
      expect(restored.name, tile.name);
      expect(restored.isActive, true);
      expect(restored.volume, 0.42);
    });
  });

  group('AmbientMix', () {
    test('JSON round-trip preserves data', () {
      final mix = AmbientMix(
        id: 'mix-1',
        name: 'Study Vibes',
        createdAt: DateTime(2026, 4, 8),
        activeSounds: {'rain': 0.7, 'vinyl': 0.3},
      );

      final json = mix.toJson();
      final restored = AmbientMix.fromJson(json);
      expect(restored.id, 'mix-1');
      expect(restored.name, 'Study Vibes');
      expect(restored.activeSounds['rain'], 0.7);
      expect(restored.activeSounds['vinyl'], 0.3);
      expect(restored.activeSounds.length, 2);
    });
  });

  group('TimerDuration', () {
    test('has correct labels', () {
      expect(TimerDuration.fifteen.label, '15m');
      expect(TimerDuration.sixty.label, '1h');
      expect(TimerDuration.infinite.label, '∞');
    });

    test('infinite has zero duration', () {
      expect(TimerDuration.infinite.duration, Duration.zero);
    });

    test('fifteen has 15 minute duration', () {
      expect(TimerDuration.fifteen.duration, const Duration(minutes: 15));
    });
  });
}
