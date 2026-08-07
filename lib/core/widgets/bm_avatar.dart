import 'package:flutter/material.dart';

class BMAvatar extends StatelessWidget {

  final String text;

  final double size;

  const BMAvatar({

    super.key,

    required this.text,

    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: size,

      height: size,

      decoration:
      const BoxDecoration(

        gradient: LinearGradient(

          colors: [

            Color(0xff0466C8),

            Color(0xff192BC2),

          ],
        ),

        shape: BoxShape.circle,
      ),

      alignment: Alignment.center,

      child: Text(

        text.isEmpty
            ? "B"
            : text[0].toUpperCase(),

        style: TextStyle(

          color: Colors.white,

          fontWeight:
          FontWeight.bold,

          fontSize: size / 2.5,
        ),
      ),
    );
  }
}