import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/configs/configs.dart';
import 'package:flutter_in_app_debugger/home/overlay_view.dart';

import 'components/network_item_widget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({
    Key? key,
  }) : super(key: key);

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
      body: FlutterInAppDebuggerView.globalKey.currentState?.requestsStream ==
              null
          ? const Center(
              child: Text('Requests stream has not been initiated yet'))
          : StreamBuilder(
              stream: FlutterInAppDebuggerView
                  .globalKey.currentState!.requestsStream.stream,
              builder: (context, _) {
                final networkRequest =
                    FlutterInAppDebuggerView.globalKey.currentState?.requests ??
                        [];
                return ListView.separated(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const NetworkDebuggerHeaderWidget();
                    }
                    // For the last line
                    else if (index == networkRequest.length + 1) {
                      return const SizedBox.shrink();
                    } else {
                      return NetworkItemWidget(
                        networkEvent: networkRequest[index - 1],
                      );
                    }
                  },
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(top: DEFAULT_PADDING / 2),
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  itemCount: networkRequest.length + 2,
                );
              },
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
      children: const [
        SizedBox(width: DEFAULT_PADDING),
        NetworkDebuggerHeaderItemWidget(title: 'API'),
        Spacer(),
        NetworkDebuggerHeaderItemWidget(title: 'STATUS'),
        SizedBox(width: DEFAULT_PADDING + 18)
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
