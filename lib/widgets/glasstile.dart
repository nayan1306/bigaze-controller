import 'package:flutter/material.dart';

Widget GlassTile(BuildContext context, String label, VoidCallback onPressed) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.15,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.1), // Light transparency
      borderRadius: BorderRadius.circular(20), // Round corners
      border: Border.all(
        width: 1,
        color: Colors.white.withOpacity(0.3), // Light border
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: const Color.fromARGB(
          60, 97, 97, 97), // Transparent material background
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // This container creates the frosted glass effect
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0)
                            .withOpacity(0.1), // Transparent white overlay
                        backgroundBlendMode: BlendMode.darken,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // child: BackdropFilter(
                      //   filter: ImageFilter.blur(
                      //       sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
                      //   child: Container(
                      //       color: Colors
                      //           .transparent), // Just a transparent container for blur
                      // ),
                    ),
                  ),
                  // Text on top of the glass effect
                  // Center(
                  //   child: Text(
                  //     label,
                  //     style: const TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       letterSpacing: 2,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
