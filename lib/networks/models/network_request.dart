class NetworkRequest<R> {
  NetworkRequest({
    required this.baseUrl,
    required this.path,
    required this.method,
    required this.uri,
    this.requestData,
    required this.requestObject,
  });

  final String baseUrl;
  final String path;
  final String method;
  final Uri uri;
  final Map<String, dynamic>? requestData;
  final R requestObject;
}
