import 'package:flutter/material.dart';
import '../models/sound_tile.dart';
import '../theme/drift_theme.dart';

class SoundTileWidget extends StatelessWidget {
  final SoundTile sound;
  final double masterVolume;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;

  const SoundTileWidget({
    super.key,
    required this.sound,
    required this.masterVolume,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = sound.isActive;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive
              ? DriftTheme.neonPink.withAlpha(30)
              : DriftTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? DriftTheme.neonPink : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: DriftTheme.neonPink.withAlpha(40),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sound.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              sound.name,
              style: TextStyle(
                color: isActive ? DriftTheme.neonPink : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 20,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: sound.volume,
                    min: 0,
                    max: 1,
                    activeColor: DriftTheme.neonCyan,
                    inactiveColor: DriftTheme.surface,
                    onChanged: onVolumeChanged,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
