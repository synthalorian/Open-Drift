import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_provider.dart';
import '../theme/synthwave_theme.dart';

class TimerPicker extends ConsumerWidget {
  const TimerPicker({super.key});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final selectedDuration = audioState.timerDuration;
    final timerActive = audioState.timerActive;
    final remaining = audioState.timerRemaining;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SynthwaveColors.surfaceDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SynthwaveColors.gridLine.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: SynthwaveColors.neonCyan,
                size: 18,
                shadows: [
                  Shadow(
                    color: SynthwaveColors.neonCyan.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'SLEEP TIMER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: SynthwaveColors.neonCyan,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              if (timerActive && remaining != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SynthwaveColors.neonCyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: SynthwaveColors.neonCyan.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _formatDuration(remaining),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SynthwaveColors.neonCyan,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...TimerDuration.values.map((d) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _TimerChip(
                        label: d.label,
                        isSelected: selectedDuration == d,
                        onTap: () => ref
                            .read(audioProvider.notifier)
                            .setTimerDuration(d),
                      ),
                    ),
                  )),
              const SizedBox(width: 8),
              _TimerActionButton(
                timerActive: timerActive,
                canStart: selectedDuration != TimerDuration.infinite,
                onStart: () =>
                    ref.read(audioProvider.notifier).startTimer(),
                onStop: () => ref.read(audioProvider.notifier).stopTimer(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimerChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? SynthwaveColors.neonCyan.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? SynthwaveColors.neonCyan
                : SynthwaveColors.gridLine,
            width: isSelected ? 1.0 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? SynthwaveColors.neonCyan
                  : SynthwaveColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerActionButton extends StatelessWidget {
  final bool timerActive;
  final bool canStart;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _TimerActionButton({
    required this.timerActive,
    required this.canStart,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: timerActive ? onStop : (canStart ? onStart : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: timerActive
              ? SynthwaveColors.neonPink.withOpacity(0.2)
              : canStart
                  ? SynthwaveColors.neonCyan.withOpacity(0.15)
                  : Colors.transparent,
          border: Border.all(
            color: timerActive
                ? SynthwaveColors.neonPink
                : canStart
                    ? SynthwaveColors.neonCyan
                    : SynthwaveColors.gridLine,
          ),
        ),
        child: Icon(
          timerActive ? Icons.stop : Icons.play_arrow,
          size: 18,
          color: timerActive
              ? SynthwaveColors.neonPink
              : canStart
                  ? SynthwaveColors.neonCyan
                  : SynthwaveColors.inactive,
        ),
      ),
    );
  }
}
