import 'dart:convert';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
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

final Client client = InterceptedClient.build(
  interceptors: [LoggingInterceptor()],
);
final Uri baseUrl = Uri(
  scheme: 'http',
  host: 'localhost',
  port: 8080,
  path: '/transactions',
);

Future<List<Transaction>> findAll() async {
  final Response response =
      await client.get(baseUrl).timeout(const Duration(seconds: 5));
  final List<dynamic> decodedJson = jsonDecode(response.body);

  final List<Transaction> transactions = [];
  for (Map<String, dynamic> transactionJson in decodedJson) {
    final Map<String, dynamic> contactJson = transactionJson['contact'];

    final Transaction transaction = Transaction(
      transactionJson['value'],
      Contact(
        0,
        contactJson['name'],
        contactJson['accountNumber'],
      ),
    );

    transactions.add(transaction);
  }

  return transactions;
}

Future<Transaction> save(Transaction transaction) async {
  final Map<String, dynamic> transactionMap = {
    'value': transaction.value,
    'contact': {
      'name': transaction.contact.name,
      'accountNumber': transaction.contact.accountNumber,
    }
  };
  final String transactionJson = jsonEncode(transactionMap);

  final Response response = await client.post(
    baseUrl,
    headers: {
      'Content-Type': 'application/json',
      'password': '1000',
    },
    body: transactionJson,
  );

  Map<String, dynamic> json = jsonDecode(response.body);
  final Map<String, dynamic> contactJson = json['contact'];

  return Transaction(
    json['value'],
    Contact(
      0,
      contactJson['name'],
      contactJson['accountNumber'],
    ),
  );
}
