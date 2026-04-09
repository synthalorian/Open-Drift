import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drift_providers.dart';
import '../theme/drift_theme.dart';

class SavedMixesScreen extends ConsumerWidget {
  const SavedMixesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mixes = ref.watch(mixStorageProvider);
    final soundNotifier = ref.read(soundProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Mixes'),
      ),
      body: mixes.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No saved mixes yet',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activate some sounds and tap Save',
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mixes.length,
              itemBuilder: (context, index) {
                final mix = mixes[index];
                return Card(
                  color: DriftTheme.card,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      mix.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${mix.activeSounds.length} sounds • ${_formatDate(mix.createdAt)}',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DriftTheme.neonPurple.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.music_note, color: DriftTheme.neonPurple),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_circle_fill, color: DriftTheme.neonCyan),
                          onPressed: () {
                            // Load this mix into the sound state
                            final sounds = ref.read(soundProvider).sounds;
                            for (final sound in sounds) {
                              if (mix.activeSounds.containsKey(sound.id)) {
                                if (!sound.isActive) soundNotifier.toggleSound(sound.id);
                                soundNotifier.setSoundVolume(
                                    sound.id, mix.activeSounds[sound.id]!);
                              } else {
                                if (sound.isActive) soundNotifier.toggleSound(sound.id);
                              }
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Loaded "${mix.name}"')),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.white24),
                          onPressed: () {
                            ref.read(mixStorageProvider.notifier).deleteMix(mix.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
