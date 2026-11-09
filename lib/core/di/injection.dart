import 'package:dashink/core/managers/auth_cache_manager.dart';
import 'package:dashink/core/managers/notification_manager.dart';
import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/network/dio_client.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/core/utils/constants/string_constants.dart';
import 'package:dashink/domain/auth/auth_repository.dart';
import 'package:dashink/domain/daily/daily_repository.dart';
import 'package:dashink/domain/leaderboard/leaderboard_repository.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:dashink/domain/purchase/purchase_repository.dart';
import 'package:dashink/domain/settings/settings_repository.dart';
import 'package:dashink/domain/shop/shop_repository.dart';
import 'package:dashink/domain/task/task_repository.dart';
import 'package:dashink/presentation/daily/bloc/daily_bloc.dart';
import 'package:dashink/presentation/game/bloc/game_bloc.dart';
import 'package:dashink/presentation/home/bloc/home_bloc.dart';
import 'package:dashink/presentation/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:dashink/presentation/settings/bloc/settings_bloc.dart';
import 'package:dashink/presentation/shop/bloc/shop_bloc.dart';
import 'package:dashink/presentation/splash/bloc/splash_bloc.dart';
import 'package:dashink/presentation/tasks/bloc/tasks_bloc.dart';
import 'package:dashink/presentation/tutorial/bloc/tutorial_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Manager / Network / Repository -> registerLazySingleton
/// Ekran BLoC'ları -> registerFactory
void configureDependencies() {
  // Backend modu: oturum, sunucu yetkili ilerleme. Mock modunda ilerleme
  // cihazda, listeler assets/mock/'tan.
  const remote = !StringConstants.useMock;
  getIt
    ..registerLazySingleton<AuthCacheManager>(
      () => AuthCacheManager(const FlutterSecureStorage()),
    )
    ..registerLazySingleton<SharedPrefManager>(() => SharedPrefManager.instance)
    ..registerLazySingleton<Dio>(
      () => DioClient.create(
        authCacheManager: getIt(),
        // Açılışta oturum açılamadıysa ilk istekte yeniden denenir.
        ensureSession: () async {
          final user = await getIt<AuthRepository>().ensureSession();
          await getIt<PurchaseRepository>().configure(appUserId: user?.id);
        },
      ),
    )
    ..registerLazySingleton<NetworkManager>(() => NetworkManager(getIt()))
    ..registerLazySingleton<SoundManager>(() => SoundManager(getIt()))
    ..registerLazySingleton<NotificationManager>(NotificationManager.new)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt(), getIt(), enabled: remote),
    )
    ..registerLazySingleton<PlayerRepository>(
      () => PlayerRepository(getIt(), remote ? getIt<NetworkManager>() : null),
    )
    ..registerLazySingleton<PurchaseRepository>(
      // Mock modunda backend yok, gerçek satın alma coin'e çevrilemez:
      // RevenueCat kapalı, örnek fiyatlar gösterilir.
      () => remote
          ? PurchaseRepository(getIt(), cache: getIt())
          : PurchaseRepository(getIt(), apiKey: ''),
    )
    ..registerLazySingleton<ShopRepository>(
      () => ShopRepository(getIt(), getIt()),
    )
    ..registerLazySingleton<TaskRepository>(
      () => TaskRepository(getIt(), getIt(), getIt(), remote: remote),
    )
    ..registerLazySingleton<LeaderboardRepository>(
      () => LeaderboardRepository(getIt()),
    )
    ..registerLazySingleton<DailyRepository>(() => DailyRepository(getIt()))
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(getIt(), getIt(), getIt()),
    )
    ..registerFactory<SplashBloc>(
      () => SplashBloc(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerFactory<TutorialBloc>(() => TutorialBloc(getIt()))
    ..registerFactory<HomeBloc>(() => HomeBloc(getIt()))
    ..registerFactory<LeaderboardBloc>(() => LeaderboardBloc(getIt()))
    ..registerFactory<DailyBloc>(() => DailyBloc(getIt()))
    ..registerFactory<ShopBloc>(
      () => ShopBloc(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerFactory<TasksBloc>(() => TasksBloc(getIt(), getIt(), getIt()))
    ..registerFactory<SettingsBloc>(
      () => SettingsBloc(getIt(), getIt(), getIt()),
    )
    ..registerFactory<GameBloc>(() => GameBloc(getIt(), getIt()));
}
