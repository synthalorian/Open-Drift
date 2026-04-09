import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ambient_mix.dart';
import '../models/sound_tile.dart';
import '../providers/audio_provider.dart';
import '../providers/mix_provider.dart';
import '../theme/synthwave_theme.dart';
import '../widgets/master_volume_slider.dart';
import '../widgets/sound_tile_widget.dart';
import '../widgets/timer_picker.dart';
import 'saved_mixes_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showSaveMixDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'SAVE MIX',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SynthwaveColors.neonCyan,
            letterSpacing: 2,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: SynthwaveColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Mix name...',
            hintStyle:
                TextStyle(color: SynthwaveColors.textSecondary.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: SynthwaveColors.gridLine),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: SynthwaveColors.neonPink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: SynthwaveColors.textSecondary,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final audioState = ref.read(audioProvider);
              final activeVolumes = audioState.activeVolumes;
              if (activeVolumes.isEmpty) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No active sounds to save'),
                  ),
                );
                return;
              }

              final mix = AmbientMix(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                soundVolumes: activeVolumes,
              );
              ref.read(mixProvider.notifier).saveMix(mix);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mix "$name" saved'),
                ),
              );
            },
            child: Text(
              'SAVE',
              style: TextStyle(
                color: SynthwaveColors.neonPink,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSoundCount =
        ref.watch(audioProvider.select((s) => s.activeSoundCount));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A3E),
              Color(0xFF0D0221),
              Color(0xFF0A0118),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar area
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Logo / title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OPENDRIFT',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: SynthwaveColors.neonCyan,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: SynthwaveColors.neonCyan
                                    .withOpacity(0.5),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'LO-FI AMBIENT GENERATOR',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: SynthwaveColors.hotPink.withOpacity(0.7),
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Active indicator
                    if (activeSoundCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SynthwaveColors.neonPink.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                SynthwaveColors.neonPink.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SynthwaveColors.neonPink,
                                boxShadow: [
                                  BoxShadow(
                                    color: SynthwaveColors.neonPink,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$activeSoundCount ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: SynthwaveColors.neonPink,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Saved mixes button
                    IconButton(
                      icon: const Icon(Icons.library_music, size: 24),
                      color: SynthwaveColors.neonCyan,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SavedMixesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Sound grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: SoundTile.allSounds.length,
                    itemBuilder: (context, index) {
                      return SoundTileWidget(
                          tile: SoundTile.allSounds[index]);
                    },
                  ),
                ),
              ),

              // Bottom controls
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    const MasterVolumeSlider(),
                    const SizedBox(height: 8),
                    const TimerPicker(),
                    const SizedBox(height: 8),
                    // Save mix button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: activeSoundCount > 0
                            ? () => _showSaveMixDialog(context, ref)
                            : null,
                        icon: Icon(
                          Icons.save,
                          size: 18,
                          color: activeSoundCount > 0
                              ? SynthwaveColors.neonPink
                              : SynthwaveColors.inactive,
                        ),
                        label: Text(
                          'SAVE CURRENT MIX',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: activeSoundCount > 0
                                ? SynthwaveColors.neonPink
                                : SynthwaveColors.inactive,
                            letterSpacing: 2,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: activeSoundCount > 0
                                  ? SynthwaveColors.neonPink.withOpacity(0.4)
                                  : SynthwaveColors.gridLine,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
