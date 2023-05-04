class NetworkRequest<R> {
  NetworkRequest({
    required this.baseUrl,
    required this.path,
    required this.method,
    required this.requestObject,
  });

  final String baseUrl;
  final String path;
  final String method;
  final R requestObject;
}
