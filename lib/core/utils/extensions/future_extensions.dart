import 'dart:async';

import 'package:dashink/core/dialogs/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';

extension FutureLoadingExtension<T> on Future<T> {
  /// Kullanıcının beklediği async işlemlerde loading dialog gösterir.
  /// Yalnızca view veya mixin'den çağrılır.
  Future<T> withLoading(BuildContext context) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopScope(
          canPop: false,
          child: LoadingDialog(),
        ),
      ),
    );

    try {
      return await this;
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}
