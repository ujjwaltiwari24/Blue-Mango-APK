import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class BMButton extends StatelessWidget {
  final String text;

  final VoidCallback? onPressed;

  final bool loading;

  final IconData? icon;

  const BMButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,

      child: ElevatedButton(
        onPressed: loading ? null : onPressed,

        child: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            if (icon != null)
              Icon(
                icon,
                size: 20,
              ),

            if (icon != null)
              const SizedBox(width: 10),

            Text(
              text,
              style:
              AppTextStyles.button,
            ),
          ],
        ),
      ),
    );
  }
}