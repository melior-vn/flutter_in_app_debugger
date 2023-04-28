import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/configs/configs.dart';
import 'package:intl/intl.dart';

import '../models/network_event.dart';

class NetworkItemWidget extends StatelessWidget {
  const NetworkItemWidget({
    Key? key,
    required this.networkEvent,
  }) : super(key: key);

  final NetworkEvent networkEvent;

  @override
  Widget build(BuildContext context) {
    var subTitle = DateFormat('kk:mm:ss').format(networkEvent.requestTime);
    if (networkEvent.responseTime != null) {
      subTitle += ' - ' +
          networkEvent.responseTime!
              .difference(networkEvent.requestTime)
              .inMilliseconds
              .toString() +
          'ms';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DEFAULT_PADDING,
        DEFAULT_PADDING * 2 / 3,
        DEFAULT_PADDING * 1.8 / 3,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  networkEvent.request.path,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: networkEvent.statusTextColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                networkEvent.status == NetworkRequestStatus.running
                    ? Container(
                        height: 14,
                        width: 14,
                        margin: const EdgeInsets.only(right: 8),
                        child: CircularProgressIndicator(
                          color: networkEvent.statusTextColor,
                        ),
                      )
                    : Container(
                        height: 10,
                        width: 10,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: networkEvent.statusTextColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
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
          ),
          const Padding(
            padding: EdgeInsets.only(left: DEFAULT_PADDING * 1.1 / 3, right: 0),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}
