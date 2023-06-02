class NetworkModel {
  String deviceId;
  String method;
  String path;
  int statusCode;
  String request;
  String response;

  NetworkModel({
    required this.deviceId,
    required this.method,
    required this.path,
    required this.statusCode,
    required this.request,
    required this.response,
  });

  Map<String, dynamic> toJson() {
    return {
      "deviceId": deviceId,
      "method": method,
      "path": path,
      "statusCode": statusCode,
      "request": request,
      "response": response,
    };
  }
}
