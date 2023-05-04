import 'package:flutter/material.dart';

import '../../configs/configs.dart';

class NetworkDebuggerHeaderWidget extends StatelessWidget {
  const NetworkDebuggerHeaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('POST'),
                  Row(
                    children: [Text('1')],
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          children: const [
            SizedBox(width: DEFAULT_PADDING),
            NetworkDebuggerHeaderItemWidget(title: 'API'),
            Spacer(),
            NetworkDebuggerHeaderItemWidget(title: 'STATUS'),
            SizedBox(width: DEFAULT_PADDING + 18)
          ],
        ),
      ],
    );
  }
}

class NetworkDebuggerHeaderItemWidget extends StatelessWidget {
  const NetworkDebuggerHeaderItemWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
