import 'package:flutter/material.dart';
import '../models/sound_tile.dart';
import '../theme/drift_theme.dart';

class TimerPicker extends StatelessWidget {
  final TimerDuration? activeTimer;
  final Duration? timeRemaining;
  final ValueChanged<TimerDuration> onSelected;
  final VoidCallback onCancel;

  const TimerPicker({
    super.key,
    required this.activeTimer,
    required this.timeRemaining,
    required this.onSelected,
    required this.onCancel,
  });

  String _formatRemaining(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (activeTimer != null && timeRemaining != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatRemaining(timeRemaining!),
                  style: TextStyle(
                    color: DriftTheme.neonCyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onCancel,
                  child: Icon(Icons.close, color: DriftTheme.neonPink, size: 20),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: TimerDuration.values.map((t) {
            final isSelected = t == activeTimer;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onSelected(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? DriftTheme.neonPink : DriftTheme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? DriftTheme.neonPink : DriftTheme.surface,
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
