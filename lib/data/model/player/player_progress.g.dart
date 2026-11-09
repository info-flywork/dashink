// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquippedItems _$EquippedItemsFromJson(Map<String, dynamic> json) =>
    EquippedItems(
      ball: json['ball'] as String? ?? 'ball_klasik',
      ink: json['ink'] as String? ?? 'ink_lacivert',
      theme: json['theme'] as String? ?? 'theme_kagit',
    );

Map<String, dynamic> _$EquippedItemsToJson(EquippedItems instance) =>
    <String, dynamic>{
      'ball': instance.ball,
      'ink': instance.ink,
      'theme': instance.theme,
    };

PlayerReward _$PlayerRewardFromJson(Map<String, dynamic> json) => PlayerReward(
  type: json['type'] as String?,
  date: json['date'] as String?,
  rank: (json['rank'] as num?)?.toInt(),
  coins: (json['coins'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerRewardToJson(PlayerReward instance) =>
    <String, dynamic>{
      'type': instance.type,
      'date': instance.date,
      'rank': instance.rank,
      'coins': instance.coins,
    };

PlayerProgress _$PlayerProgressFromJson(Map<String, dynamic> json) =>
    PlayerProgress(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      bestScore: (json['best_score'] as num?)?.toInt() ?? 0,
      gamesPlayed: (json['games_played'] as num?)?.toInt() ?? 0,
      tutorialSeen: json['tutorial_seen'] as bool? ?? false,
      premium: json['premium'] as bool? ?? false,
      ownedItems:
          (json['owned_items'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['ball_klasik', 'ink_lacivert', 'theme_kagit'],
      equipped: json['equipped'] == null
          ? const EquippedItems()
          : EquippedItems.fromJson(json['equipped'] as Map<String, dynamic>),
      rewards:
          (json['rewards'] as List<dynamic>?)
              ?.map((e) => PlayerReward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PlayerProgressToJson(PlayerProgress instance) =>
    <String, dynamic>{
      'user': instance.user?.toJson(),
      'coins': instance.coins,
      'best_score': instance.bestScore,
      'games_played': instance.gamesPlayed,
      'tutorial_seen': instance.tutorialSeen,
      'premium': instance.premium,
      'owned_items': instance.ownedItems,
      'equipped': instance.equipped.toJson(),
      'rewards': instance.rewards.map((e) => e.toJson()).toList(),
    };
