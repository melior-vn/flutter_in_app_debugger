import 'package:flutter/material.dart';

import '../../configs/configs.dart';

class TextLogoWidget extends StatelessWidget {
  const TextLogoWidget({
    Key? key,
    required this.text,
    this.backgroundColor,
  }) : super(key: key);

  final String text;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DEFAULT_PADDING * 1.7,
      height: DEFAULT_PADDING * 1.7,
      padding: const EdgeInsets.all(DEFAULT_PADDING / 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: FittedBox(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
