import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    debugPrint('Request');
    debugPrint('base url: ${data.baseUrl}');
    debugPrint('headers: ${data.headers}');
    debugPrint('body: ${data.body}');
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    debugPrint('Response');
    debugPrint('status code: ${data.statusCode}');
    debugPrint('headers: ${data.headers}');
    debugPrint('body: ${data.body}');
    return data;
  }
}

void findAll() async {
  final Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );
  final Uri url = Uri(
    scheme: 'http',
    host: 'localhost',
    port: 8080,
    path: '/transactions',
  );
  final Response response = await client.get(url);
}
