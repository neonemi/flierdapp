

import '../../../di/injection.dart';
import '../../../repository/get_user_contract.dart';
import 'chatcontract.dart';

class ChatPresenter {

  ChatContract _view;

  late UserRepository _repository;

  ChatPresenter(this._view) {
    _repository = new Injector().userRepository;
  }

  void loadUsers() {
    assert(_view != null);

    _repository
        .fetchUser()
        .then((userlist) => _view.showUserList(userlist))
        .catchError((onError) {
      print(onError);
      _view.showError();
    });
  }
}