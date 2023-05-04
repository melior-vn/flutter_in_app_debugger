import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/configs/configs.dart';
import 'package:flutter_in_app_debugger/networks/views/request_detail_view.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import 'network_status_widget.dart';

class NetworkItemWidget extends StatelessWidget {
  const NetworkItemWidget({
    Key? key,
    required this.networkEvent,
    this.logo,
    this.logoPadding = const EdgeInsets.only(right: DEFAULT_PADDING * 0.9),
  }) : super(key: key);

  final NetworkEvent networkEvent;
  final Widget? logo;
  final EdgeInsets logoPadding;

  @override
  Widget build(BuildContext context) {
    var subTitle = DateFormat('kk:mm:ss').format(networkEvent.requestTime);
    if (networkEvent.responseTime != null) {
      subTitle += ' - ' +
          networkEvent.responseTime!
              .difference(networkEvent.requestTime)
              .inMilliseconds
              .toString() +
          ' ms';
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestDetailView(networkEvent: networkEvent),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DEFAULT_PADDING * 0.9,
          DEFAULT_PADDING * 2 / 3,
          DEFAULT_PADDING * 1.8 / 3,
          0,
        ),
        child: Row(
          children: [
            if (logo != null)
              Padding(
                padding: logoPadding,
                child: logo!,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    networkEvent.request.path,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: DEFAULT_PADDING / 4),
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
            NetworkStatusWidget(networkEvent: networkEvent),
            const Padding(
              padding:
                  EdgeInsets.only(left: DEFAULT_PADDING * 1.4 / 3, right: 0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
