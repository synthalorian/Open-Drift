import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ambient_mix.dart';

/// Persists saved ambient mixes using Hive local storage.
class MixStorageService {
  static const String _boxName = 'saved_mixes';

  Box<String> get _safeBox {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    throw StateError('MixStorageService: Box "$_boxName" is not open.');
  }

  Future<void> saveMix(AmbientMix mix) async {
    final json = jsonEncode(mix.toJson());
    await _safeBox.put(mix.id, json);
  }

  Future<void> deleteMix(String mixId) async {
    await _safeBox.delete(mixId);
  }

  List<AmbientMix> loadAllMixes() {
    final mixes = <AmbientMix>[];
    for (final key in _safeBox.keys) {
      try {
        final json = _safeBox.get(key);
        if (json != null) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          mixes.add(AmbientMix.fromJson(map));
        }
      } catch (e) {
        // Skip corrupted entries
        continue;
      }
    }
    mixes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mixes;
  }

  Future<void> close() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box<String>(_boxName).close();
    }
  }
}
