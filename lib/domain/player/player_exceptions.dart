import 'package:dashink/core/network/network_exception.dart';

/// Altın yetmedi (`insufficient_coins`).
final class InsufficientCoinsException implements Exception {
  const InsufficientCoinsException();
}

/// Öğe coin ile alınamaz: görev / premium / varsayılan (`item_locked`).
final class ItemLockedException implements Exception {
  const ItemLockedException();
}

/// Görev henüz tamamlanmadı veya ödülü alındı.
final class TaskNotClaimableException implements Exception {
  const TaskNotClaimableException();
}

/// Oyuncu adı geçersiz (uzunluk / karakter).
final class InvalidPlayerNameException implements Exception {
  const InvalidPlayerNameException();
}

/// DB `users.name` VARCHAR(32) ile aynı sınırlar.
const int playerNameMin = 2;
const int playerNameMax = 32;

final _playerNamePattern = RegExp(r"^[\p{L}\p{N} _.\-']+$", unicode: true);

/// Trim + iç boşlukları tek boşluğa indirger.
/// Geçersizse [InvalidPlayerNameException].
String normalizePlayerName(String raw) {
  final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (name.length < playerNameMin || name.length > playerNameMax) {
    throw const InvalidPlayerNameException();
  }
  if (!_playerNamePattern.hasMatch(name)) {
    throw const InvalidPlayerNameException();
  }
  return name;
}

/// Sunucunun makine okunur hata kodunu domain istisnasına çevirir.
Exception mapPlayerError(NetworkException e) => switch (e.message) {
  'insufficient_coins' => const InsufficientCoinsException(),
  'item_locked' || 'not_owned' => const ItemLockedException(),
  'task_not_complete' || 'already_claimed' => const TaskNotClaimableException(),
  _ => e,
};
