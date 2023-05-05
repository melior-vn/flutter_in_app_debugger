import 'package:flutter/material.dart';

import '../models/models.dart';

class NetworkStatusWidget extends StatelessWidget {
  const NetworkStatusWidget({
    Key? key,
    required this.networkEvent,
  }) : super(key: key);

  final NetworkEvent networkEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: networkEvent.statusTextColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height:
                networkEvent.status == NetworkRequestStatus.running ? 14 : 10,
            width:
                networkEvent.status == NetworkRequestStatus.running ? 14 : 10,
            margin: EdgeInsets.only(
                right: networkEvent.status == NetworkRequestStatus.running
                    ? 8
                    : 5),
            decoration: networkEvent.status == NetworkRequestStatus.running
                ? null
                : BoxDecoration(
                    color: networkEvent.statusTextColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
            child: networkEvent.status == NetworkRequestStatus.running
                ? CircularProgressIndicator(
                    color: networkEvent.statusTextColor,
                  )
                : null,
          ),
          Text(
            networkEvent.statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: networkEvent.statusTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
