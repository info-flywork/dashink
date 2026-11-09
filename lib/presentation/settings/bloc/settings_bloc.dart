import 'dart:async';

import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/domain/player/player_exceptions.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:dashink/domain/purchase/purchase_repository.dart';
import 'package:dashink/domain/settings/settings_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SettingsToggle { sfx, music, vibration, notifications }

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsToggled extends SettingsEvent {
  const SettingsToggled(
    this.toggle, {
    required this.enabled,
    this.notificationTitle = '',
    this.notificationBody = '',
  });

  final SettingsToggle toggle;
  final bool enabled;

  /// Bildirim metinleri (yerelleştirilmiş, view'dan).
  final String notificationTitle;
  final String notificationBody;

  @override
  List<Object?> get props => [toggle, enabled];
}

final class SettingsRestoreRequested extends SettingsEvent {
  const SettingsRestoreRequested();
}

final class SettingsNameSaveRequested extends SettingsEvent {
  const SettingsNameSaveRequested(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class _SettingsProgressChanged extends SettingsEvent {
  const _SettingsProgressChanged(this.progress);

  final PlayerProgress progress;

  @override
  List<Object?> get props => [progress];
}

enum SettingsEffect {
  none,
  notificationsDenied,
  restored,
  nothingToRestore,
  nameSaved,
  nameInvalid,
  error,
}

class SettingsState extends Equatable {
  const SettingsState({
    required this.sfx,
    required this.music,
    required this.vibration,
    required this.notifications,
    this.playerName = '',
    this.effect = SettingsEffect.none,
    this.busy = false,
  });

  final bool sfx;
  final bool music;
  final bool vibration;
  final bool notifications;
  final String playerName;

  /// View'ın bir kez göstereceği sonuç.
  final SettingsEffect effect;
  final bool busy;

  SettingsState copyWith({
    bool? sfx,
    bool? music,
    bool? vibration,
    bool? notifications,
    String? playerName,
    SettingsEffect effect = SettingsEffect.none,
    bool busy = false,
  }) => SettingsState(
    sfx: sfx ?? this.sfx,
    music: music ?? this.music,
    vibration: vibration ?? this.vibration,
    notifications: notifications ?? this.notifications,
    playerName: playerName ?? this.playerName,
    effect: effect,
    busy: busy,
  );

  @override
  List<Object?> get props => [
    sfx,
    music,
    vibration,
    notifications,
    playerName,
    effect,
    busy,
  ];
}

/// Ses / müzik / titreşim / bildirim tercihleri, isim ve satın alım geri yükleme.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._settings, this._purchases, this._player)
    : super(
        SettingsState(
          sfx: _settings.isSfxEnabled,
          music: _settings.isMusicEnabled,
          vibration: _settings.isVibrationEnabled,
          notifications: _settings.isNotificationsEnabled,
          playerName: _player.progress.user?.name ?? '',
        ),
      ) {
    on<SettingsToggled>(_onToggled);
    on<SettingsRestoreRequested>(_onRestore);
    on<SettingsNameSaveRequested>(_onNameSave);
    on<_SettingsProgressChanged>(_onProgressChanged);
    _subscription = _player.changes.listen(
      (p) => add(_SettingsProgressChanged(p)),
    );
  }

  final SettingsRepository _settings;
  final PurchaseRepository _purchases;
  final PlayerRepository _player;
  late final StreamSubscription<PlayerProgress> _subscription;

  void _onProgressChanged(
    _SettingsProgressChanged event,
    Emitter<SettingsState> emit,
  ) {
    final name = event.progress.user?.name ?? '';
    if (name != state.playerName) {
      emit(state.copyWith(playerName: name));
    }
  }

  Future<void> _onToggled(
    SettingsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final on = event.enabled;
    switch (event.toggle) {
      case SettingsToggle.sfx:
        emit(state.copyWith(sfx: on));
        await _settings.setSfxEnabled(enabled: on);
      case SettingsToggle.music:
        emit(state.copyWith(music: on));
        await _settings.setMusicEnabled(enabled: on);
      case SettingsToggle.vibration:
        emit(state.copyWith(vibration: on));
        await _settings.setVibrationEnabled(enabled: on);
      case SettingsToggle.notifications:
        emit(state.copyWith(notifications: on));
        final ok = await _settings.setNotificationsEnabled(
          enabled: on,
          title: event.notificationTitle,
          body: event.notificationBody,
        );
        if (!ok) {
          emit(
            state.copyWith(
              notifications: false,
              effect: SettingsEffect.notificationsDenied,
            ),
          );
        }
    }
  }

  Future<void> _onRestore(
    SettingsRestoreRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    try {
      final premium = await _purchases.restore();
      emit(
        state.copyWith(
          effect: premium
              ? SettingsEffect.restored
              : SettingsEffect.nothingToRestore,
        ),
      );
    } on Exception {
      emit(state.copyWith(effect: SettingsEffect.error));
    }
  }

  Future<void> _onNameSave(
    SettingsNameSaveRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    try {
      final progress = await _player.updateName(event.name);
      emit(
        state.copyWith(
          playerName: progress.user?.name ?? '',
          effect: SettingsEffect.nameSaved,
        ),
      );
    } on InvalidPlayerNameException {
      emit(state.copyWith(effect: SettingsEffect.nameInvalid));
    } on Exception {
      emit(state.copyWith(effect: SettingsEffect.error));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
