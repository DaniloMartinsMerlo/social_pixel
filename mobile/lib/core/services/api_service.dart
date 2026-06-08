import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:mobile/core/constants/api_constants.dart';

class ApiService {
  const ApiService();

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _sendJson('GET', path, queryParameters: queryParameters, headers: headers);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _sendJson('POST', path, body: body, queryParameters: queryParameters, headers: headers);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _sendJson('PATCH', path, body: body, queryParameters: queryParameters, headers: headers);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _sendJson('DELETE', path, body: body, queryParameters: queryParameters, headers: headers);
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = ApiConstants.uri(path, queryParameters);
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    final response = await switch (method) {
      'GET' => http.get(uri, headers: requestHeaders),
      'POST' => http.post(uri, headers: requestHeaders, body: jsonEncode(body ?? const {})),
      'PATCH' => http.patch(uri, headers: requestHeaders, body: jsonEncode(body ?? const {})),
      'DELETE' => http.delete(uri, headers: requestHeaders, body: body == null ? null : jsonEncode(body)),
      _ => throw UnsupportedError('Unsupported method: $method'),
    };

    final decodedBody = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    final error = decodedBody['error']?.toString() ?? 'Request failed (${response.statusCode})';
    throw ApiException(error, statusCode: response.statusCode);
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}