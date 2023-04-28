import 'package:flutter/material.dart';

import 'components/network_item_widget.dart';
import 'models/network_event.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({
    Key? key,
    required this.networkRequest,
  }) : super(key: key);

  final List<NetworkEvent> networkRequest;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Network Debugger',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: NetworkDebuggerHeaderWidget(),
            );
          }
          // For the last line
          else if (index == widget.networkRequest.length) {
            return const SizedBox.shrink();
          } else {
            return NetworkItemWidget(
              networkEvent: widget.networkRequest[index - 1],
            );
          }
        },
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(top: 4),
          width: double.infinity,
          height: 1,
          color: Colors.grey.withOpacity(0.1),
        ),
        itemCount: widget.networkRequest.length + 1,
      ),
    );
  }
}

class NetworkDebuggerHeaderWidget extends StatelessWidget {
  const NetworkDebuggerHeaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        NetworkDebuggerHeaderItemWidget(title: 'API'),
        NetworkDebuggerHeaderItemWidget(title: 'STATUS'),
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
