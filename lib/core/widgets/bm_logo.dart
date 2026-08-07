import 'package:flutter/material.dart';

class BMLogo extends StatelessWidget {
  final double size;

  const BMLogo({
    super.key,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "bm_logo",

      child: Container(
        height: size,
        width: size,

        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(28),

          gradient:
          const LinearGradient(
            colors: [
              Color(0xff0466C8),
              Color(0xff192BC2),
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: const Color(
                0xff0466C8,
              ).withOpacity(.35),

              blurRadius: 30,

              spreadRadius: 2,
            ),
          ],
        ),

        child: const Icon(
          Icons.auto_awesome,

          color: Colors.white,

          size: 42,
        ),
      ),
    );
  }
}