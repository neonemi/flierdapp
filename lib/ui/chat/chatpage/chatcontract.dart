
import '../../../model/GetChatUsers.dart';

abstract class ChatContract {

  void showUserList(List<Data> items);

  void showError();
}