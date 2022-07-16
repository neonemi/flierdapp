import 'dart:convert';
import 'package:http/http.dart';
import 'dart:convert' as convert;
import 'chatpageview.dart';

class ChatPagePresenter {
  ChatPageView _view;
  ChatPagePresenter(this._view);
  var snackBar;
  void getChatUsers() async {
    Response response =
        await get(Uri.parse("https://mvendorshop.askme.im/api/v1/chat-users"));
    var jsonResponse = convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        _view.chatuser(
            response.body,
            jsonDecode(response.body)['data'],
            jsonDecode(response.body)['data']['chat_not_started_yet_users'],
            jsonDecode(response.body)['data']['chat_with_users']);
        var venam = jsonDecode(response.body)['data']
                ['chat_not_started_yet_users']
            .toString();
        var venamid =
            jsonDecode(response.body)['data']['chat_with_users'].toString();
        print(venam.toString());
        print(venamid.toString());
      } else {
        print(response.statusCode);
      }
    } else {
      print(response.statusCode);
    }
  }
}
