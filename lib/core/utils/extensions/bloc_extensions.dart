import 'package:bloc/bloc.dart';

extension BlocAwaitExtension<E, S> on Bloc<E, S> {
  /// Event'i ekler ve `until` koşulunu sağlayan ilk state'i bekler.
  /// View/mixin'de `.withLoading(context)` ile birlikte kullanılır:
  ///
  /// ```dart
  /// final state = await bloc
  ///     .addAndWait(const XSubmitted(), until: (s) => s is! XInProgress)
  ///     .withLoading(context);
  /// ```
  Future<S> addAndWait(E event, {required bool Function(S state) until}) {
    final future = stream.firstWhere(until);
    add(event);
    return future;
  }
}
