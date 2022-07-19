class GetChatUsers {
  bool? success;
  String? message;
  Data? data;
  GetChatUsers({
    required this.success,
    required this.message,
    required this.data,
  });

  GetChatUsers.fromMap(Map<String, dynamic> map)
      : success = map['success'],
        message = map['message'],
        data = map['data'];
}

class Data {
  List<ChatNotStartedYetUsers>? chatNotStartedYetUsers;
  List<ChatWithUsers>? chatWithUsers;
  Data({
    required this.chatNotStartedYetUsers,
    required this.chatWithUsers,
  });
  Data.fromMap(Map<String, dynamic> map)
      : chatNotStartedYetUsers = map['chat_not_started_yet_users'],
        chatWithUsers = map['chat_with_users'];
}

class ChatWithUsers {
  int? id;
  String? name;
  String? profilePicUrl;
  LastGamePlayedWithUser? lastGamePlayedWithUser;
  ChatWithUsers({
    required this.id,
    required this.name,
    required this.profilePicUrl,
    required this.lastGamePlayedWithUser,
  });

  ChatWithUsers.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        profilePicUrl = map['profile_pic_url'],
        lastGamePlayedWithUser = map['last_game_played_with_user'];
}

class LastGamePlayedWithUser {
  int? id;
  String? gameName;
  String? gamePicUrl;
  LastGamePlayedWithUser(
      {required this.id, required this.gameName, required this.gamePicUrl});

  LastGamePlayedWithUser.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        gameName = map['game_name'],
        gamePicUrl = map['game_pic_url'];
}

class ChatNotStartedYetUsers {
  int? id;
  String? name;
  String? profilePicUrl;
  ChatNotStartedYetUsers({
    required this.id,
    required this.name,
    required this.profilePicUrl,
  });

  ChatNotStartedYetUsers.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        profilePicUrl = map['profile_pic_url'];
}
