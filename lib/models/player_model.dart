class PlayerModel {
  final String id;
  final String name;
  final int ballsScored;
  final int fouls;
  final int avatarIndex; // 0, 1, or 2 — randomly assigned

  const PlayerModel({
    required this.id,
    required this.name,
    required this.ballsScored,
    this.fouls = 0,
    this.avatarIndex = 0,
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    int? ballsScored,
    int? fouls,
    int? avatarIndex,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ballsScored: ballsScored ?? this.ballsScored,
      fouls: fouls ?? this.fouls,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
