import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

enum SnackBarType {
  success(color: ColorName.mint, icon: Icons.check_circle_outline),
  failure(color: ColorName.tomato, icon: Icons.error_outline),
  info(color: ColorName.ink, icon: Icons.info_outline);

  const SnackBarType({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}

enum SnackBarPosition { top, bottom }
