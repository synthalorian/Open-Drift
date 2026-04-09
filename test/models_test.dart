import 'package:flutter_test/flutter_test.dart';
import 'package:open_drift/models/sound_tile.dart';
import 'package:open_drift/models/ambient_mix.dart';

void main() {
  group('SoundTile', () {
    test('allSounds contains 10 sounds', () {
      expect(SoundTile.allSounds.length, 10);
    });

    test('all sound IDs are unique', () {
      final ids = SoundTile.allSounds.map((s) => s.id).toSet();
      expect(ids.length, SoundTile.allSounds.length);
    });

    test('equality based on ID', () {
      final a = SoundTile.allSounds[0];
      final b = SoundTile.allSounds[0];
      expect(a, equals(b));
    });

    test('toJson returns correct map', () {
      final tile = SoundTile.allSounds.first;
      final json = tile.toJson();
      expect(json['id'], 'rain');
      expect(json['name'], 'Rain');
      expect(json['assetPath'], 'assets/audio/rain.mp3');
    });

    test('each sound has required fields', () {
      for (final sound in SoundTile.allSounds) {
        expect(sound.id.isNotEmpty, true);
        expect(sound.name.isNotEmpty, true);
        expect(sound.assetPath.isNotEmpty, true);
        expect(sound.assetPath.startsWith('assets/audio/'), true);
      }
    });
  });

  group('AmbientMix', () {
    test('creates with required fields', () {
      final mix = AmbientMix(
        id: 'test-1',
        name: 'Test Mix',
        soundVolumes: {'rain': 0.8, 'wind': 0.5},
      );
      expect(mix.id, 'test-1');
      expect(mix.name, 'Test Mix');
      expect(mix.soundVolumes.length, 2);
      expect(mix.soundVolumes['rain'], 0.8);
    });

    test('toJson and fromJson roundtrip', () {
      final original = AmbientMix(
        id: 'test-2',
        name: 'Rainy Night',
        soundVolumes: {'rain': 0.9, 'thunder': 0.4, 'vinyl_crackle': 0.6},
        createdAt: DateTime(2026, 4, 8, 22, 0),
      );

      final json = original.toJson();
      final restored = AmbientMix.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.soundVolumes, original.soundVolumes);
      expect(restored.createdAt, original.createdAt);
    });

    test('copyWith creates modified copy', () {
      final mix = AmbientMix(
        id: 'test-3',
        name: 'Original',
        soundVolumes: {'rain': 0.5},
      );

      final modified = mix.copyWith(name: 'Modified');
      expect(modified.name, 'Modified');
      expect(modified.id, mix.id);
      expect(modified.soundVolumes, mix.soundVolumes);
    });

    test('equality based on ID', () {
      final a = AmbientMix(
        id: 'same-id',
        name: 'Mix A',
        soundVolumes: {'rain': 0.5},
      );
      final b = AmbientMix(
        id: 'same-id',
        name: 'Mix B',
        soundVolumes: {'wind': 0.8},
      );
      expect(a, equals(b));
    });

    test('toString returns readable format', () {
      final mix = AmbientMix(
        id: 'test-4',
        name: 'Chill',
        soundVolumes: {'rain': 0.5, 'forest': 0.7},
      );
      expect(mix.toString(), contains('Chill'));
      expect(mix.toString(), contains('2'));
    });
  });
}
