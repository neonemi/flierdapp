import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/GetChatUsers.dart';
import '../utils/fetch_data_exception.dart';
import 'get_user_contract.dart';

class GetUserRepository implements UserRepository {
  static const url = 'https://mvendorshop.askme.im/api/v1/chat-users';
  final JsonDecoder _decoder = JsonDecoder();

  @override
  Future<List<Data>> fetchUser() {
    return http.get(Uri.parse(url)).then((http.Response response) {
      final String jsonBody = response.body;
      final statusCode = response.statusCode;

      if (statusCode != 200 || jsonBody==null) {
        throw new FetchDataException(
            "Error while getting user [StatusCode:$statusCode, Error:${response.reasonPhrase}]");
      }

      final userContainer = _decoder.convert(jsonBody);
      final List userdata = userContainer['data'];

      return userdata
          .map((userdatalist) => Data.fromMap(userdatalist))
          .toList();
    });
  }
}
