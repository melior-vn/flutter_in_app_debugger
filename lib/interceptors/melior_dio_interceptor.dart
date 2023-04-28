import 'dart:async';

import 'package:dio/dio.dart';

import '../home/overlay_view.dart';

enum FakeDataType { response, error }

class MeliorDioInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _onRequest(options);
    super.onRequest(options, handler);
  }

  void _onRequest(RequestOptions options) {
    FlutterInAppDebuggerView.globalKey.currentState?.addNetworkRequest(
      request: options,
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _onReponse(response);
    super.onResponse(response, handler);
  }

  void _onReponse(Response response) {
    FlutterInAppDebuggerView.globalKey.currentState?.addNetworkResponse(
      response: response,
    );
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    _onError(err);
    super.onError(err, handler);
  }

  void _onError(DioError err) {
    FlutterInAppDebuggerView.globalKey.currentState?.addNetworkError(
      dioError: err,
    );
  }

  Timer fakeData({
    FakeDataType fakeDataType = FakeDataType.response,
    Response? fakeResponse,
    DioError? fakeError,
    Duration duration = const Duration(seconds: 1),
    Duration responseTime = const Duration(seconds: 1),
    int? numberOfRepetions,
  }) {
    var currentNumberOfRepetions = 0;
    final timer = Timer.periodic(duration, (timer) {
      if (numberOfRepetions != null) {
        currentNumberOfRepetions += 1;
      }

      final requestOptions = RequestOptions(
          path: 'fakePath/fakePath/$currentNumberOfRepetions', method: 'POST');
      _onRequest(requestOptions);
      Future.delayed(responseTime).then((value) {
        switch (fakeDataType) {
          case FakeDataType.response:
            _onReponse(fakeResponse ??
                Response(
                  requestOptions: requestOptions,
                  statusCode: 200,
                  statusMessage: 'Success',
                ));
            break;
          case FakeDataType.error:
            _onError(fakeError ??
                DioError(
                  requestOptions: requestOptions,
                  message: 'DioError',
                ));
            break;
        }
      });
      if (currentNumberOfRepetions == numberOfRepetions) {
        timer.cancel();
      }
    });
    return timer;
  }
}
