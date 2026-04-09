import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ambient_mix.dart';
import '../services/mix_storage_service.dart';

/// State notifier for managing saved mixes.
class MixNotifier extends StateNotifier<List<AmbientMix>> {
  final MixStorageService _storage;

  MixNotifier(this._storage) : super([]) {
    _loadMixes();
  }

  void _loadMixes() {
    try {
      state = _storage.loadAllMixes();
    } catch (_) {
      state = [];
    }
  }

  Future<void> saveMix(AmbientMix mix) async {
    await _storage.saveMix(mix);
    _loadMixes();
  }

  Future<void> deleteMix(String mixId) async {
    await _storage.deleteMix(mixId);
    _loadMixes();
  }

  void refresh() => _loadMixes();
}

/// Providers
final mixStorageServiceProvider = Provider<MixStorageService>((ref) {
  final service = MixStorageService();
  ref.onDispose(() => service.close());
  return service;
});

final mixProvider = StateNotifierProvider<MixNotifier, List<AmbientMix>>((ref) {
  final storage = ref.watch(mixStorageServiceProvider);
  return MixNotifier(storage);
});
