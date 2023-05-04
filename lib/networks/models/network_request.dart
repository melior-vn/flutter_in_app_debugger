class NetworkRequest<R> {
  NetworkRequest({
    required this.baseUrl,
    required this.path,
    required this.method,
    this.requestData,
    required this.requestObject,
  });

  final String baseUrl;
  final String path;
  final String method;
  final Map<String, dynamic>? requestData;
  final R requestObject;
}
