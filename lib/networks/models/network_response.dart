class NetworkResponse<T> {
  NetworkResponse({
    required this.response,
    required this.statusCode,
  });

  final T response;
  final int statusCode;
}
