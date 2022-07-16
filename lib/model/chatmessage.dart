import 'dart:typed_data';

import 'package:video_player/video_player.dart';

class ChatMessage{
  String messagetext;
  String messageType;
  String imagepath;
  String videopath;
  DateTime messagetime;
  Uint8List? uint8list;
  VideoPlayerController? videoController;
  String audio;
  String filepath;
  String filename;
  ChatMessage({required this.messagetext, required this.messageType,required this.imagepath,
    required this.videopath,required this.messagetime,required this.uint8list,required this.videoController,
    required this.audio,required this.filepath,required this.filename});
}