import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
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
      var jsonResponse = convert.jsonDecode(response.body);
      if (statusCode != 200 || jsonResponse['success']!=null) {
        throw FetchDataException(
            "Error while getting user [StatusCode:$statusCode, Error:${response.reasonPhrase}]");
      }

      final userContainer = _decoder.convert(jsonBody);
      final List userdata = jsonResponse['data'];
      log(userdata.toString());
      return userdata
          .map((userdatalist) => Data.fromMap(userdatalist))
          .toList();
    });
  }
}
