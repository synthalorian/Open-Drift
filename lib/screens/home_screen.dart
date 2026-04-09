import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drift_providers.dart';
import '../widgets/sound_tile_widget.dart';
import '../widgets/timer_picker.dart';
import '../theme/drift_theme.dart';
import 'saved_mixes_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundState = ref.watch(soundProvider);
    final notifier = ref.read(soundProvider.notifier);
    final activeCount = soundState.activeSounds.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Open', style: TextStyle(color: DriftTheme.neonPink)),
            const Text('Drift'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedMixesScreen()),
            ),
          ),
          if (activeCount > 0)
            IconButton(
              icon: Icon(Icons.stop_circle_outlined, color: DriftTheme.neonPink),
              onPressed: notifier.stopAll,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Master volume
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.volume_down, color: DriftTheme.neonCyan, size: 20),
                  Expanded(
                    child: Slider(
                      value: soundState.masterVolume,
                      min: 0,
                      max: 1,
                      onChanged: notifier.setMasterVolume,
                    ),
                  ),
                  Icon(Icons.volume_up, color: DriftTheme.neonCyan, size: 20),
                ],
              ),
            ),
            // Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TimerPicker(
                activeTimer: soundState.activeTimer,
                timeRemaining: soundState.timeRemaining,
                onSelected: notifier.startTimer,
                onCancel: notifier.cancelTimer,
              ),
            ),
            const SizedBox(height: 16),
            // Sound grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: soundState.sounds.length,
                itemBuilder: (context, index) {
                  final sound = soundState.sounds[index];
                  return SoundTileWidget(
                    sound: sound,
                    masterVolume: soundState.masterVolume,
                    onToggle: () => notifier.toggleSound(sound.id),
                    onVolumeChanged: (v) => notifier.setSoundVolume(sound.id, v),
                  );
                },
              ),
            ),
            // Active count + save
            if (activeCount > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DriftTheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$activeCount sound${activeCount == 1 ? '' : 's'} active',
                      style: TextStyle(color: DriftTheme.neonCyan),
                    ),
                    TextButton.icon(
                      onPressed: () => _showSaveDialog(context, ref),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Mix'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DriftTheme.card,
        title: const Text('Save Mix'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Mix name...',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: DriftTheme.neonPink),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final activeSounds = ref.read(soundProvider).activeSounds;
                ref.read(mixStorageProvider.notifier).saveMix(name, activeSounds);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved "$name"')),
                );
              }
            },
            child: Text('Save', style: TextStyle(color: DriftTheme.neonPink)),
          ),
        ],
      ),
    );
  }
}
