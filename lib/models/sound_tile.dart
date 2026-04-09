import 'package:flutter/material.dart';

enum SoundCategory {
  nature,
  mechanical,
  ambient,
  musical,
}

class SoundTile {
  final String id;
  final String name;
  final String assetPath;
  final IconData icon;
  final SoundCategory category;
  final Color accentColor;

  const SoundTile({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.icon,
    required this.category,
    required this.accentColor,
  });

  static const List<SoundTile> allSounds = [
    SoundTile(
      id: 'rain',
      name: 'Rain',
      assetPath: 'assets/audio/rain.mp3',
      icon: Icons.water_drop,
      category: SoundCategory.nature,
      accentColor: Color(0xFF00D4FF),
    ),
    SoundTile(
      id: 'vinyl_crackle',
      name: 'Vinyl Crackle',
      assetPath: 'assets/audio/vinyl_crackle.mp3',
      icon: Icons.album,
      category: SoundCategory.mechanical,
      accentColor: Color(0xFFFF6EC7),
    ),
    SoundTile(
      id: 'tape_hiss',
      name: 'Tape Hiss',
      assetPath: 'assets/audio/tape_hiss.mp3',
      icon: Icons.radio,
      category: SoundCategory.mechanical,
      accentColor: Color(0xFFFFB347),
    ),
    SoundTile(
      id: 'synth_drone',
      name: 'Synth Drone',
      assetPath: 'assets/audio/synth_drone.mp3',
      icon: Icons.piano,
      category: SoundCategory.musical,
      accentColor: Color(0xFFBF40BF),
    ),
    SoundTile(
      id: 'thunder',
      name: 'Thunder',
      assetPath: 'assets/audio/thunder.mp3',
      icon: Icons.bolt,
      category: SoundCategory.nature,
      accentColor: Color(0xFFE0E722),
    ),
    SoundTile(
      id: 'wind',
      name: 'Wind',
      assetPath: 'assets/audio/wind.mp3',
      icon: Icons.air,
      category: SoundCategory.nature,
      accentColor: Color(0xFF87CEEB),
    ),
    SoundTile(
      id: 'fireplace',
      name: 'Fireplace',
      assetPath: 'assets/audio/fireplace.mp3',
      icon: Icons.local_fire_department,
      category: SoundCategory.ambient,
      accentColor: Color(0xFFFF6347),
    ),
    SoundTile(
      id: 'cafe',
      name: 'Cafe',
      assetPath: 'assets/audio/cafe.mp3',
      icon: Icons.coffee,
      category: SoundCategory.ambient,
      accentColor: Color(0xFFD2691E),
    ),
    SoundTile(
      id: 'ocean_waves',
      name: 'Ocean Waves',
      assetPath: 'assets/audio/ocean_waves.mp3',
      icon: Icons.waves,
      category: SoundCategory.nature,
      accentColor: Color(0xFF1E90FF),
    ),
    SoundTile(
      id: 'forest',
      name: 'Forest',
      assetPath: 'assets/audio/forest.mp3',
      icon: Icons.forest,
      category: SoundCategory.nature,
      accentColor: Color(0xFF32CD32),
    ),
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'assetPath': assetPath,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundTile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
