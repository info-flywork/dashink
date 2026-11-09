import 'package:dashink/core/base/model/base_model.dart';
import 'package:dashink/data/model/auth/user.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player_progress.g.dart';

/// Kuşanılmış öğeler (top, mürekkep, tema).
@JsonSerializable()
class EquippedItems extends Equatable {
  const EquippedItems({
    this.ball = 'ball_klasik',
    this.ink = 'ink_lacivert',
    this.theme = 'theme_kagit',
  });

  factory EquippedItems.fromJson(Map<String, dynamic> json) =>
      _$EquippedItemsFromJson(json);

  static const String defaultBall = 'ball_klasik';
  static const String defaultInk = 'ink_lacivert';
  static const String defaultTheme = 'theme_kagit';

  final String ball;
  final String ink;
  final String theme;

  Map<String, dynamic> toJson() => _$EquippedItemsToJson(this);

  EquippedItems copyWith({String? ball, String? ink, String? theme}) =>
      EquippedItems(
        ball: ball ?? this.ball,
        ink: ink ?? this.ink,
        theme: theme ?? this.theme,
      );

  @override
  List<Object?> get props => [ball, ink, theme];
}

/// Sunucunun bu istekte yeni yüklediği ödül (ör. günlük sıralama ödülü).
@JsonSerializable()
class PlayerReward extends Equatable {
  const PlayerReward({this.type, this.date, this.rank, this.coins = 0});

  factory PlayerReward.fromJson(Map<String, dynamic> json) =>
      _$PlayerRewardFromJson(json);

  final String? type;
  final String? date;
  final int? rank;
  final int coins;

  Map<String, dynamic> toJson() => _$PlayerRewardToJson(this);

  @override
  List<Object?> get props => [type, date, rank, coins];
}

/// Oyuncu ilerlemesi: `GET /player/progress` ve mağaza işlemlerinin cevabı.
@JsonSerializable()
class PlayerProgress extends Equatable implements BaseModel<PlayerProgress> {
  const PlayerProgress({
    this.user,
    this.coins = 0,
    this.bestScore = 0,
    this.gamesPlayed = 0,
    this.tutorialSeen = false,
    this.premium = false,
    this.ownedItems = const ['ball_klasik', 'ink_lacivert', 'theme_kagit'],
    this.equipped = const EquippedItems(),
    this.rewards = const [],
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) =>
      _$PlayerProgressFromJson(json);

  static const List<String> defaultItems = [
    EquippedItems.defaultBall,
    EquippedItems.defaultInk,
    EquippedItems.defaultTheme,
  ];

  final User? user;
  final int coins;
  final int bestScore;
  final int gamesPlayed;
  final bool tutorialSeen;
  final bool premium;
  final List<String> ownedItems;
  final EquippedItems equipped;
  final List<PlayerReward> rewards;

  bool owns(String itemId) => ownedItems.contains(itemId);

  bool isEquipped(String itemId) =>
      equipped.ball == itemId ||
      equipped.ink == itemId ||
      equipped.theme == itemId;

  PlayerProgress copyWith({
    User? user,
    int? coins,
    int? bestScore,
    int? gamesPlayed,
    bool? tutorialSeen,
    bool? premium,
    List<String>? ownedItems,
    EquippedItems? equipped,
    List<PlayerReward>? rewards,
  }) => PlayerProgress(
    user: user ?? this.user,
    coins: coins ?? this.coins,
    bestScore: bestScore ?? this.bestScore,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    premium: premium ?? this.premium,
    ownedItems: ownedItems ?? this.ownedItems,
    equipped: equipped ?? this.equipped,
    rewards: rewards ?? this.rewards,
  );

  @override
  PlayerProgress fromJson(Map<String, dynamic> json) =>
      PlayerProgress.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerProgressToJson(this);

  @override
  List<Object?> get props => [
    user,
    coins,
    bestScore,
    gamesPlayed,
    tutorialSeen,
    premium,
    ownedItems,
    equipped,
    rewards,
  ];
}
