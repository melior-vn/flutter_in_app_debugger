import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/configs/configs.dart';
import 'package:flutter_in_app_debugger/console/console_view.dart';
import 'package:flutter_in_app_debugger/networks/views/network_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter In-app Debugger',
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
          if (index == 0 || index == 3) {
            return const SizedBox.shrink();
          } else if (index == 1) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NetworkView(),
                ),
              ),
              behavior: HitTestBehavior.translucent,
              child: const HomeViewItemWidget(
                text: 'NETWORK',
                icon: Icons.network_wifi_rounded,
              ),
            );
          } else {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConsoleView(),
                ),
              ),
              behavior: HitTestBehavior.translucent,
              child: const HomeViewItemWidget(
                text: 'CONSOLE',
                icon: Icons.bug_report,
              ),
            );
          }
        },
        separatorBuilder: (_, __) => Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.withOpacity(0.1),
        ),
        itemCount: 4,
      ),
    );
  }
}

class HomeViewItemWidget extends StatelessWidget {
  const HomeViewItemWidget({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DEFAULT_PADDING),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DEFAULT_PADDING,
            ),
            child: Icon(icon),
          ),
          Expanded(
              child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          )),
          const Padding(
            padding: EdgeInsets.only(
              left: DEFAULT_PADDING * 1.4 / 3,
              right: DEFAULT_PADDING,
            ),
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
