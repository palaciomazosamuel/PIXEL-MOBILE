import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.compact = false, this.onDark = false, super.key});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.violet, AppColors.info],
            ),
            borderRadius: BorderRadius.circular(compact ? 14 : 16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x336C5CE7),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PIXEL',
              style: AppTextStyles.titleMedium.copyWith(
                color: onDark ? Colors.white : AppColors.ink,
                letterSpacing: 0,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!compact)
              Text(
                'Sistema de Gestión',
                style: AppTextStyles.label.copyWith(
                  color: onDark ? const Color(0xFFDDE6FF) : AppColors.muted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
