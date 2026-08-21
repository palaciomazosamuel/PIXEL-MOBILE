import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const titleLarge = TextStyle(
    color: AppColors.ink,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const titleMedium = TextStyle(
    color: AppColors.ink,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    color: AppColors.ink,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const bodyStrong = TextStyle(
    color: AppColors.ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const bodyMuted = TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    color: AppColors.muted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
