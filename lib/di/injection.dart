
import '../repository/get_user_contract.dart';
import '../repository/get_users.dart';

class Injector {

  static final Injector _singleton = Injector._internal();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  UserRepository get userRepository {
    return GetUserRepository();
  }
}