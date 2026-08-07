import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class BMCard extends StatelessWidget {

  final Widget child;

  final EdgeInsetsGeometry? padding;

  const BMCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: padding ??
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: AppColors.card,

        borderRadius:
        BorderRadius.circular(
          AppRadius.xxl,
        ),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: child,
    );
  }
}