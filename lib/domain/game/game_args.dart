import 'package:dashink/domain/game/game_record.dart';

/// Oyun ekranına geçilen parametreler. Normal oyunda seed rastgeledir;
/// günlük meydan okumada sunucunun verdiği ortak seed kullanılır.
class GameArgs {
  const GameArgs({this.mode = GameMode.normal, this.seed, this.dailyDate});

  final GameMode mode;
  final int? seed;
  final String? dailyDate;
}
