import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_tile.dart';
import '../providers/audio_provider.dart';
import '../theme/synthwave_theme.dart';

class SoundTileWidget extends ConsumerWidget {
  final SoundTile tile;

  const SoundTileWidget({super.key, required this.tile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundState = ref.watch(
      audioProvider.select((s) => s.sounds[tile.id]),
    );
    final isActive = soundState?.isActive ?? false;
    final volume = soundState?.volume ?? 0.7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive
            ? tile.accentColor.withValues(alpha: 0.15)
            : SynthwaveColors.cardBackground,
        border: Border.all(
          color: isActive ? tile.accentColor : SynthwaveColors.cardBorder,
          width: isActive ? 1.5 : 0.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: tile.accentColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ref.read(audioProvider.notifier).toggleSound(tile.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with glow effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    tile.icon,
                    size: 36,
                    color: isActive
                        ? tile.accentColor
                        : SynthwaveColors.inactive,
                    shadows: isActive
                        ? [
                            Shadow(
                              color: tile.accentColor.withValues(alpha: 0.6),
                              blurRadius: 20,
                            ),
                          ]
                        : [],
                  ),
                ),
                const SizedBox(height: 8),
                // Sound name
                Text(
                  tile.name.toUpperCase().replaceAll(' ', '\n'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? tile.accentColor
                        : SynthwaveColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Volume slider (only visible when active)
                AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: 20,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: tile.accentColor,
                        inactiveTrackColor:
                            tile.accentColor.withValues(alpha: 0.2),
                        thumbColor: tile.accentColor,
                        overlayColor: tile.accentColor.withValues(alpha: 0.15),
                        trackHeight: 2,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 5),
                      ),
                      child: Slider(
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: isActive
                            ? (v) => ref
                                .read(audioProvider.notifier)
                                .setSoundVolume(tile.id, v)
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
