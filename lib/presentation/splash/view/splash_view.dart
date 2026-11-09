import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/presentation/splash/bloc/splash_bloc.dart';
import 'package:dashink/presentation/splash/bloc/splash_state.dart';
import 'package:dashink/presentation/tutorial/view/tutorial_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/splash_view_mixin.dart';
part 'widgets/splash_typewriter.dart';

/// Splash: `#03624C` zemin, beyaz harf harf "flywork".
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SplashViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: onStateChanged,
      child: const Scaffold(
        backgroundColor: ColorName.splashBackground,
        body: Center(child: SplashTypewriter(text: 'flywork')),
      ),
    );
  }
}
