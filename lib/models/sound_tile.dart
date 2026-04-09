class SoundTile {
  final String id;
  final String name;
  final String icon;
  final String assetPath;
  bool isActive;
  double volume;

  SoundTile({
    required this.id,
    required this.name,
    required this.icon,
    required this.assetPath,
    this.isActive = false,
    this.volume = 0.7,
  });

  SoundTile copyWith({
    bool? isActive,
    double? volume,
  }) {
    return SoundTile(
      id: id,
      name: name,
      icon: icon,
      assetPath: assetPath,
      isActive: isActive ?? this.isActive,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'assetPath': assetPath,
        'isActive': isActive,
        'volume': volume,
      };

  factory SoundTile.fromJson(Map<String, dynamic> json) => SoundTile(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        assetPath: json['assetPath'] as String,
        isActive: json['isActive'] as bool? ?? false,
        volume: (json['volume'] as num?)?.toDouble() ?? 0.7,
      );
}

class AmbientMix {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<String, double> activeSounds; // soundId -> volume

  AmbientMix({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.activeSounds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'activeSounds': activeSounds,
      };

  factory AmbientMix.fromJson(Map<String, dynamic> json) => AmbientMix(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        activeSounds: Map<String, double>.from(
          (json['activeSounds'] as Map).map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ),
        ),
      );
}

enum TimerDuration {
  fifteen(Duration(minutes: 15), '15m'),
  thirty(Duration(minutes: 30), '30m'),
  sixty(Duration(minutes: 60), '1h'),
  twoHours(Duration(hours: 2), '2h'),
  infinite(Duration.zero, '∞');

  final Duration duration;
  final String label;
  const TimerDuration(this.duration, this.label);
}
