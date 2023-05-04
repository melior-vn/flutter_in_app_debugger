class NetworkResponse<T> {
  NetworkResponse({
    required this.response,
    this.responseData,
    required this.statusCode,
  });

  final T response;
  final Map<String, dynamic>? responseData;
  final int statusCode;
}
