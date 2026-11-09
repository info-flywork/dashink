import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// "Bildirimler" ayarı: günlük meydan okuma hatırlatması (yerel bildirim,
/// günde bir). Metinler çağıran taraftan yerelleştirilmiş gelir.
class NotificationManager {
  NotificationManager([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int _dailyId = 1;

  Future<void> _init() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// İzin ister ve günlük hatırlatmayı kurar. İzin verilmezse false.
  Future<bool> enableDaily({
    required String title,
    required String body,
  }) async {
    try {
      await _init();
      final granted = await _requestPermission();
      if (!granted) return false;
      await _plugin.periodicallyShow(
        id: _dailyId,
        title: title,
        body: body,
        repeatInterval: RepeatInterval.daily,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_challenge',
            'Daily challenge',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
      return true;
    } on Object catch (e) {
      debugPrint('NotificationManager: kurulamadı: $e');
      return false;
    }
  }

  Future<void> disableDaily() async {
    try {
      await _init();
      await _plugin.cancel(id: _dailyId);
    } on Object catch (e) {
      debugPrint('NotificationManager: iptal edilemedi: $e');
    }
  }

  Future<bool> _requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }
}
