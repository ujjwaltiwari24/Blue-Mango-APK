import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BMLoader extends StatelessWidget {

  const BMLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return const Center(

      child:
      CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}