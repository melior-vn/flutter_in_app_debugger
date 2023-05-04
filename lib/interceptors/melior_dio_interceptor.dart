import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import '../networks/models/models.dart';

import '../home/overlay_view.dart';

enum FakeDataType { response, error, onlyRequest, randomResponse }

class MeliorDioInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _onRequest(options);
    super.onRequest(options, handler);
  }

  void _onRequest(RequestOptions options) {
    FlutterInAppDebuggerView.globalKey.currentState?.addNetworkRequest(
      request: options,
      baseUrl: options.baseUrl,
      path: options.path,
      method: options.method,
      data: options.data,
      type: InterceptorType.dio,
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
      statusCode: response.statusCode ?? 999,
      responseData: response.data,
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
        path: 'fakePath/fakePath/$currentNumberOfRepetions',
        method: 'POST',
        data: {'key': 'value'},
      );
      _onRequest(requestOptions);
      Future.delayed(responseTime).then((value) {
        switch (fakeDataType) {
          case FakeDataType.response:
            _onReponse(
              fakeResponse ??
                  Response(
                    requestOptions: requestOptions,
                    statusCode: 200,
                    statusMessage: 'Success',
                    data: {'key': 'value'},
                  ),
            );
            break;
          case FakeDataType.error:
            _onError(fakeError ??
                DioError(
                  requestOptions: requestOptions,
                ));
            break;
          case FakeDataType.randomResponse:
            final isResponse = Random().nextBool();
            if (isResponse) {
              _onReponse(
                fakeResponse ??
                    Response(
                      requestOptions: requestOptions,
                      statusCode: 200,
                      statusMessage: 'Success',
                      data: {'key': 'value'},
                    ),
              );
            } else {
              _onError(fakeError ??
                  DioError(
                    requestOptions: requestOptions,
                  ));
            }

            break;
          case FakeDataType.onlyRequest:
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
