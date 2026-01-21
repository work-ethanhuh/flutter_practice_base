import 'package:dio/dio.dart';

import 'interceptor/api_interceptor.dart';

class ApiClients {
  static final ApiClients _instance = ApiClients._internal();
  factory ApiClients() => _instance;
  final Dio token;
  final Dio nonToken;
  final int nonTokenConnectTimeOut;
  final int nonTokenReceiveTimeout;
  final int tokenConnectTimeOut;
  final int tokenReceiveTimeout;
  final bool enableLogger;

  ApiClients._internal({
    this.enableLogger = true,
    this.nonTokenConnectTimeOut = 10000,
    this.nonTokenReceiveTimeout = 10000,
    this.tokenConnectTimeOut = 10000,
    this.tokenReceiveTimeout = 10000,
  })  : token = Dio()
          ..options.connectTimeout = Duration(milliseconds: tokenConnectTimeOut)
          ..options.receiveTimeout = Duration(milliseconds: tokenReceiveTimeout)
          ..options.headers = <String, String>{
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json'
          }
          ..interceptors.add(ApiInterceptor(enableLogger: enableLogger)),
        nonToken = Dio()
          ..options.connectTimeout =
              Duration(milliseconds: nonTokenConnectTimeOut)
          ..options.receiveTimeout =
              Duration(milliseconds: nonTokenReceiveTimeout)
          ..options.headers = <String, String>{
            'content-type': 'application/json; charset=utf-8',
            'accept': 'application/json'
          }
          ..interceptors.add(
              ApiInterceptor(enableLogger: enableLogger, needToken: false));
}
