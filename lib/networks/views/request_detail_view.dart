import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_in_app_debugger/networks/models/network_event.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum RequestActionType { copyRequest, copyResponse, copycURL }

class RequestDetailView extends StatefulWidget {
  const RequestDetailView({
    Key? key,
    required this.networkEvent,
  }) : super(key: key);

  final NetworkEvent networkEvent;

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Detail View',
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
        actions: [
          PopupMenuButton<RequestActionType>(
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.black,
            ),
            onSelected: (RequestActionType item) async {
              switch (item) {
                case RequestActionType.copyRequest:
                  await Clipboard.setData(
                    ClipboardData(
                      text: (widget.networkEvent.request.requestData ?? {})
                          .toString(),
                    ),
                  );
                  Fluttertoast.showToast(
                    msg: 'Copied request to clipboard',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white70.withOpacity(0.8),
                    textColor: Colors.black,
                    fontSize: 14.0,
                  );
                  break;
                case RequestActionType.copyResponse:
                  await Clipboard.setData(
                    ClipboardData(
                      text: (widget.networkEvent.response?.responseData ?? {})
                          .toString(),
                    ),
                  );
                  Fluttertoast.showToast(
                    msg: 'Copied response to clipboard',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white70.withOpacity(0.8),
                    textColor: Colors.black,
                    fontSize: 14.0,
                  );
                  break;
                case RequestActionType.copycURL:
                  await Clipboard.setData(
                    ClipboardData(text: widget.networkEvent.getcURL),
                  );
                  Fluttertoast.showToast(
                    msg: 'Copied cURL to clipboard',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white70.withOpacity(0.8),
                    textColor: Colors.black,
                    fontSize: 14.0,
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<RequestActionType>>[
              PopupMenuItem<RequestActionType>(
                value: RequestActionType.copyRequest,
                child: Row(children: const [
                  Icon(
                    Icons.upload_rounded,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text('Copy request')
                ]),
              ),
              PopupMenuItem<RequestActionType>(
                value: RequestActionType.copyResponse,
                child: Row(children: const [
                  Icon(
                    Icons.download_rounded,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text('Copy response')
                ]),
              ),
              PopupMenuItem<RequestActionType>(
                value: RequestActionType.copycURL,
                child: Row(children: [
                  SvgPicture.asset(
                    'assets/postman_logo.svg',
                    package: 'flutter_in_app_debugger',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Copy cURL')
                ]),
              ),
            ],
          ),
        ],
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TabBar(
            indicatorColor: Colors.black,
            tabs: const [
              RequestDetailTabBarItem(
                text: 'Request',
              ),
              RequestDetailTabBarItem(
                text: 'Response',
              ),
            ],
            controller: _tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                JsonView.map(widget.networkEvent.request.requestData ?? {}),
                JsonView.map(widget.networkEvent.response?.responseData ?? {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestDetailTabBarItem extends StatelessWidget {
  const RequestDetailTabBarItem({
    Key? key,
    required String text,
  })  : _text = text,
        super(key: key);

  final String _text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
