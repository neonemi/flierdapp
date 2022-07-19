import 'dart:async';


import '../model/GetChatUsers.dart';

abstract class UserRepository {
  Future<List<Data>> fetchUser();
}