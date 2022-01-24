import 'dart:convert';
import 'dart:io';

import 'package:dhis2_flutter_sdk/modules/auth/user/entities/user.entity.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/queries/user.query.dart';
import 'package:dhis2_flutter_sdk/shared/utilities/http-details.util.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

class HttpResponse {
  late int statusCode;
  late dynamic body;
  HttpResponse({required int statusCode, required dynamic body}) {
    this.statusCode = statusCode;
    this.body = body;
  }
}

class HttpClient {
  findById() {}

  update() {}

  // static Future<Response> create(String url, data) {
  //   return http.post(
  //     Uri.parse(url),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'title': data,
  //     }),
  //   );
  // }

  static Future<HttpResponse> get(String resourceUrl,
      {String? baseUrl,
      String? username,
      String? password,
      Database? database,
      Dio? dioTestClient}) async {
    HttpDetails httpDetails = await HttpDetails(
            baseUrl: baseUrl,
            username: username,
            password: password,
            database: database)
        .get();

    final dioClient = dioTestClient ??
        Dio(BaseOptions(
            connectTimeout: 100000,
            receiveTimeout: 100000,
            headers: {
              HttpHeaders.authorizationHeader: 'Basic ${httpDetails.authToken}',
            }));

    try {
      final Response<dynamic> response =
          await dioClient.get('${httpDetails.baseUrl}/api/$resourceUrl');

      return HttpResponse(
          statusCode: response.statusCode ?? 500, body: response.data);
    } catch (error) {
      throw Exception(error);
    }
  }

  // static Future<http.Response> delete(String id, String url) async {
  //   final http.Response response = await http.delete(
  //     Uri.parse('$url/$id'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'Basic'
  //     },
  //   );

  //   return response;
  // }

  static Future<String> getHttpDetails(
      {String? baseUrl,
      String? username,
      String? password,
      Database? database}) async {
    if (username != null && password != null) {
      return base64Encode(utf8.encode('$username:$password'));
    }

    final User? user = await UserQuery(database: database).getOne();

    return base64Encode(utf8.encode('${user?.username}:${user?.password}'));
  }
}
