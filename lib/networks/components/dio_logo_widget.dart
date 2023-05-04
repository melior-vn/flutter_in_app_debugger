import 'package:flutter/material.dart';

import '../../configs/configs.dart';

class DioLogoWidget extends StatelessWidget {
  const DioLogoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DEFAULT_PADDING * 1.7,
      height: DEFAULT_PADDING * 1.7,
      padding: const EdgeInsets.all(DEFAULT_PADDING / 4),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: FittedBox(
          child: Text(
            'Dio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
