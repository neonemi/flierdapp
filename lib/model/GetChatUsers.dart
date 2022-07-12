import 'dart:convert';
/// success : true
/// message : "Chat users"
/// data : {"chat_not_started_yet_users":[{"id":1,"name":"User 1","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 1"},{"id":2,"name":"User 2","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 2"},{"id":3,"name":"User 3","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 3"},{"id":4,"name":"User 4","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 4"},{"id":5,"name":"User 5","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 5"},{"id":6,"name":"User 6","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 6"}],"chat_with_users":[{"id":7,"name":"User 7","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 7","last_game_played_with_user":{"id":1,"game_name":"Game name 1","game_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=Game 1"}},{"id":8,"name":"User 8","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 8","last_game_played_with_user":{"id":2,"game_name":"Game name 2","game_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=Game 2"}},{"id":9,"name":"User 9","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 9","last_game_played_with_user":""},{"id":10,"name":"User 10","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 10","last_game_played_with_user":""},{"id":11,"name":"User 11","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 11","last_game_played_with_user":""},{"id":12,"name":"User 12","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 12","last_game_played_with_user":""}]}

GetChatUsers getChatUsersFromJson(String str) => GetChatUsers.fromJson(json.decode(str));
String getChatUsersToJson(GetChatUsers data) => json.encode(data.toJson());
class GetChatUsers {
  GetChatUsers({
      bool? success, 
      String? message, 
      Data? data,}){
    _success = success;
    _message = message;
    _data = data;
}

  GetChatUsers.fromJson(dynamic json) {
    _success = json['success'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _success;
  String? _message;
  Data? _data;
GetChatUsers copyWith({  bool? success,
  String? message,
  Data? data,
}) => GetChatUsers(  success: success ?? _success,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get success => _success;
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// chat_not_started_yet_users : [{"id":1,"name":"User 1","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 1"},{"id":2,"name":"User 2","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 2"},{"id":3,"name":"User 3","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 3"},{"id":4,"name":"User 4","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 4"},{"id":5,"name":"User 5","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 5"},{"id":6,"name":"User 6","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 6"}]
/// chat_with_users : [{"id":7,"name":"User 7","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 7","last_game_played_with_user":{"id":1,"game_name":"Game name 1","game_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=Game 1"}},{"id":8,"name":"User 8","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 8","last_game_played_with_user":{"id":2,"game_name":"Game name 2","game_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=Game 2"}},{"id":9,"name":"User 9","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 9","last_game_played_with_user":""},{"id":10,"name":"User 10","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 10","last_game_played_with_user":""},{"id":11,"name":"User 11","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 11","last_game_played_with_user":""},{"id":12,"name":"User 12","profile_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 12","last_game_played_with_user":""}]

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      List<ChatNotStartedYetUsers>? chatNotStartedYetUsers, 
      List<ChatWithUsers>? chatWithUsers,}){
    _chatNotStartedYetUsers = chatNotStartedYetUsers;
    _chatWithUsers = chatWithUsers;
}

  Data.fromJson(dynamic json) {
    if (json['chat_not_started_yet_users'] != null) {
      _chatNotStartedYetUsers = [];
      json['chat_not_started_yet_users'].forEach((v) {
        _chatNotStartedYetUsers?.add(ChatNotStartedYetUsers.fromJson(v));
      });
    }
    if (json['chat_with_users'] != null) {
      _chatWithUsers = [];
      json['chat_with_users'].forEach((v) {
        _chatWithUsers?.add(ChatWithUsers.fromJson(v));
      });
    }
  }
  List<ChatNotStartedYetUsers>? _chatNotStartedYetUsers;
  List<ChatWithUsers>? _chatWithUsers;
Data copyWith({  List<ChatNotStartedYetUsers>? chatNotStartedYetUsers,
  List<ChatWithUsers>? chatWithUsers,
}) => Data(  chatNotStartedYetUsers: chatNotStartedYetUsers ?? _chatNotStartedYetUsers,
  chatWithUsers: chatWithUsers ?? _chatWithUsers,
);
  List<ChatNotStartedYetUsers>? get chatNotStartedYetUsers => _chatNotStartedYetUsers;
  List<ChatWithUsers>? get chatWithUsers => _chatWithUsers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_chatNotStartedYetUsers != null) {
      map['chat_not_started_yet_users'] = _chatNotStartedYetUsers?.map((v) => v.toJson()).toList();
    }
    if (_chatWithUsers != null) {
      map['chat_with_users'] = _chatWithUsers?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 7
/// name : "User 7"
/// profile_pic_url : "https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 7"
/// last_game_played_with_user : {"id":1,"game_name":"Game name 1","game_pic_url":"https://dummyimage.com/600x400/5fa9f8/efefef.png&text=Game 1"}

ChatWithUsers chatWithUsersFromJson(String str) => ChatWithUsers.fromJson(json.decode(str));
String chatWithUsersToJson(ChatWithUsers data) => json.encode(data.toJson());
class ChatWithUsers {
  ChatWithUsers({
      int? id, 
      String? name, 
      String? profilePicUrl, 
      LastGamePlayedWithUser? lastGamePlayedWithUser,}){
    _id = id;
    _name = name;
    _profilePicUrl = profilePicUrl;
    _lastGamePlayedWithUser = lastGamePlayedWithUser;
}

  ChatWithUsers.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _profilePicUrl = json['profile_pic_url'];
    _lastGamePlayedWithUser = json['last_game_played_with_user'] != null ? LastGamePlayedWithUser.fromJson(json['last_game_played_with_user']) : null;
  }
  int? _id;
  String? _name;
  String? _profilePicUrl;
  LastGamePlayedWithUser? _lastGamePlayedWithUser;
ChatWithUsers copyWith({  int? id,
  String? name,
  String? profilePicUrl,
  LastGamePlayedWithUser? lastGamePlayedWithUser,
}) => ChatWithUsers(  id: id ?? _id,
  name: name ?? _name,
  profilePicUrl: profilePicUrl ?? _profilePicUrl,
  lastGamePlayedWithUser: lastGamePlayedWithUser ?? _lastGamePlayedWithUser,
);
  int? get id => _id;
  String? get name => _name;
  String? get profilePicUrl => _profilePicUrl;
  LastGamePlayedWithUser? get lastGamePlayedWithUser => _lastGamePlayedWithUser;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['profile_pic_url'] = _profilePicUrl;
    if (_lastGamePlayedWithUser != null) {
      map['last_game_played_with_user'] = _lastGamePlayedWithUser?.toJson();
    }
    return map;
  }

}

/// id : 1
/// game_name : "Game name 1"
/// game_pic_url : "https://dummyimage.com/600x400/5fa9f8/efefef.png&text=Game 1"

LastGamePlayedWithUser lastGamePlayedWithUserFromJson(String str) => LastGamePlayedWithUser.fromJson(json.decode(str));
String lastGamePlayedWithUserToJson(LastGamePlayedWithUser data) => json.encode(data.toJson());
class LastGamePlayedWithUser {
  LastGamePlayedWithUser({
      int? id, 
      String? gameName, 
      String? gamePicUrl,}){
    _id = id;
    _gameName = gameName;
    _gamePicUrl = gamePicUrl;
}

  LastGamePlayedWithUser.fromJson(dynamic json) {
    _id = json['id'];
    _gameName = json['game_name'];
    _gamePicUrl = json['game_pic_url'];
  }
  int? _id;
  String? _gameName;
  String? _gamePicUrl;
LastGamePlayedWithUser copyWith({  int? id,
  String? gameName,
  String? gamePicUrl,
}) => LastGamePlayedWithUser(  id: id ?? _id,
  gameName: gameName ?? _gameName,
  gamePicUrl: gamePicUrl ?? _gamePicUrl,
);
  int? get id => _id;
  String? get gameName => _gameName;
  String? get gamePicUrl => _gamePicUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['game_name'] = _gameName;
    map['game_pic_url'] = _gamePicUrl;
    return map;
  }

}

/// id : 1
/// name : "User 1"
/// profile_pic_url : "https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 1"

ChatNotStartedYetUsers chatNotStartedYetUsersFromJson(String str) => ChatNotStartedYetUsers.fromJson(json.decode(str));
String chatNotStartedYetUsersToJson(ChatNotStartedYetUsers data) => json.encode(data.toJson());
class ChatNotStartedYetUsers {
  ChatNotStartedYetUsers({
      int? id, 
      String? name, 
      String? profilePicUrl,}){
    _id = id;
    _name = name;
    _profilePicUrl = profilePicUrl;
}

  ChatNotStartedYetUsers.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _profilePicUrl = json['profile_pic_url'];
  }
  int? _id;
  String? _name;
  String? _profilePicUrl;
ChatNotStartedYetUsers copyWith({  int? id,
  String? name,
  String? profilePicUrl,
}) => ChatNotStartedYetUsers(  id: id ?? _id,
  name: name ?? _name,
  profilePicUrl: profilePicUrl ?? _profilePicUrl,
);
  int? get id => _id;
  String? get name => _name;
  String? get profilePicUrl => _profilePicUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['profile_pic_url'] = _profilePicUrl;
    return map;
  }

}