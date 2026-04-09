class AmbientMix {
  final String id;
  final String name;
  final Map<String, double> soundVolumes; // soundId -> volume (0.0 - 1.0)
  final DateTime createdAt;

  AmbientMix({
    required this.id,
    required this.name,
    required this.soundVolumes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AmbientMix copyWith({
    String? id,
    String? name,
    Map<String, double>? soundVolumes,
    DateTime? createdAt,
  }) {
    return AmbientMix(
      id: id ?? this.id,
      name: name ?? this.name,
      soundVolumes: soundVolumes ?? Map.from(this.soundVolumes),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'soundVolumes': soundVolumes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AmbientMix.fromJson(Map<String, dynamic> json) {
    return AmbientMix(
      id: json['id'] as String,
      name: json['name'] as String,
      soundVolumes: Map<String, double>.from(
        (json['soundVolumes'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbientMix && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AmbientMix(id: $id, name: $name, sounds: ${soundVolumes.length})';
}
