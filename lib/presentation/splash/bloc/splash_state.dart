import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Hazırlık bitti. İlk açılışta eğitime, sonra ana ekrana gidilir.
final class SplashReady extends SplashState {
  const SplashReady({required this.showTutorial});

  final bool showTutorial;

  @override
  List<Object?> get props => [showTutorial];
}
