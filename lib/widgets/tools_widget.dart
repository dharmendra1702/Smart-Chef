import 'dart:ui';

import 'package:flutter/material.dart';

class ToolWidget extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final Function onTap;
  final double size;

  const ToolWidget({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    required this.onTap,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(size * 0.136),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size * 0.136),
                bottomRight: Radius.circular(size * 0.136),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ),
                child: Container(
                  height: size * 0.318,
                  width: size,
                  decoration: const BoxDecoration(
                    color: Color(0x8C000100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
