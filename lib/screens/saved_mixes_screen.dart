import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ambient_mix.dart';
import '../models/sound_tile.dart';
import '../providers/audio_provider.dart';
import '../providers/mix_provider.dart';
import '../theme/synthwave_theme.dart';

class SavedMixesScreen extends ConsumerWidget {
  const SavedMixesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mixes = ref.watch(mixProvider);

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
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      color: SynthwaveColors.neonCyan,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SAVED MIXES',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SynthwaveColors.neonCyan,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: SynthwaveColors.neonCyan
                                .withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${mixes.length} MIX${mixes.length == 1 ? '' : 'ES'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: SynthwaveColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Mixes list
              Expanded(
                child: mixes.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: mixes.length,
                        itemBuilder: (context, index) {
                          return _MixCard(mix: mixes[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 64,
            color: SynthwaveColors.inactive,
          ),
          const SizedBox(height: 16),
          Text(
            'NO SAVED MIXES YET',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SynthwaveColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an atmosphere and save it for later',
            style: TextStyle(
              fontSize: 13,
              color: SynthwaveColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MixCard extends ConsumerWidget {
  final AmbientMix mix;

  const _MixCard({required this.mix});

  String _formatDate(DateTime date) {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<SoundTile> _getSoundTiles(Map<String, double> volumes) {
    return SoundTile.allSounds
        .where((t) => volumes.containsKey(t.id))
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = _getSoundTiles(mix.soundVolumes);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: SynthwaveColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: SynthwaveColors.cardBorder.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              ref.read(audioProvider.notifier).loadMix(mix.soundVolumes);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Loaded "${mix.name}"'),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mix.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SynthwaveColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: SynthwaveColors.textSecondary,
                        onPressed: () {
                          _showDeleteConfirmation(context, ref);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(mix.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: SynthwaveColors.textSecondary.withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Sound icons row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tiles.map((tile) {
                      final volume = mix.soundVolumes[tile.id] ?? 0.7;
                      return _SoundChip(tile: tile, volume: volume);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'DELETE MIX',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SynthwaveColors.neonPink,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Remove "${mix.name}" from saved mixes?',
          style: const TextStyle(color: SynthwaveColors.textPrimary),
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
              ref.read(mixProvider.notifier).deleteMix(mix.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'DELETE',
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
}

class _SoundChip extends StatelessWidget {
  final SoundTile tile;
  final double volume;

  const _SoundChip({required this.tile, required this.volume});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tile.accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tile.accentColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tile.icon,
            size: 14,
            color: tile.accentColor,
          ),
          const SizedBox(width: 4),
          Text(
            tile.name,
            style: TextStyle(
              fontSize: 11,
              color: tile.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(volume * 100).round()}%',
            style: TextStyle(
              fontSize: 10,
              color: tile.accentColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
