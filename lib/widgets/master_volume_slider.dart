import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../theme/synthwave_theme.dart';

class MasterVolumeSlider extends ConsumerWidget {
  const MasterVolumeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masterVolume = ref.watch(audioProvider.select((s) => s.masterVolume));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: SynthwaveColors.surfaceDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SynthwaveColors.gridLine.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            masterVolume > 0.5
                ? Icons.volume_up
                : masterVolume > 0
                    ? Icons.volume_down
                    : Icons.volume_mute,
            color: SynthwaveColors.neonPink,
            size: 22,
            shadows: [
              Shadow(
                color: SynthwaveColors.neonPink.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: SynthwaveColors.neonPink,
                inactiveTrackColor: SynthwaveColors.sliderTrack,
                thumbColor: SynthwaveColors.hotPink,
                overlayColor: SynthwaveColors.neonPink.withValues(alpha: 0.2),
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: masterVolume,
                min: 0.0,
                max: 1.0,
                onChanged: (v) =>
                    ref.read(audioProvider.notifier).setMasterVolume(v),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(masterVolume * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SynthwaveColors.neonPink,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
