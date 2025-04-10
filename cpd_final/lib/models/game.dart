class Game {
  final String id;
  final String name;
  final String platform;
  final String progress;
  final String lastPlayed;
  final String? location;

  Game({
    required this.id,
    required this.name,
    required this.platform,
    required this.progress,
    required this.lastPlayed,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'progress': progress,
      'lastPlayed': lastPlayed,
      'location': location,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map, String id) {
    return Game(
      id: id,
      name: map['name'] ?? 'Unknown',
      platform: map['platform'] ?? 'Unknown',
      progress: map['progress'] ?? 'Unknown',
      lastPlayed: map['lastPlayed'] ?? 'Unknown',
      location: map['location'],
    );
  }
}
