import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

import '../../../../model/chatmessage.dart';
import '../camera/videoplayer.dart';
import '../mainscreen/chatscreen.dart';

class Imageview extends StatefulWidget{
  var filepath;
  var type;
  var videopath;
  String? imagePath;
  VideoPlayerController? videoController;
  final cameras;
  String name="";
  String image="";
  List<ChatMessage>? chatmessage;
  BuildContext? context;
  int chatid;
  Imageview({Key? key,required  this.filepath,required this.type,required this.videopath,required this.chatmessage,
    required this.videoController,required this.imagePath,
    required this.image,required this.name,required this.cameras,required this.context,required this.chatid}) : super(key: key);
  @override
  ImageViewState createState() => ImageViewState();

}
class ImageViewState extends State<Imageview>{

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);

  }
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) =>  ChatScreen(cameras: widget.cameras, image: widget.image,name: widget.name,chatmessage: widget.chatmessage, chatid: widget.chatid,)));

    // Do some stuff.
    return true;
  }

  @override
  Widget build(BuildContext context) {
   return
    Scaffold(
      backgroundColor: Colors.white.withOpacity(0.85),
      body: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Column(
              children: [
                widget.type==2? NetworkPlayerLifeCycle(
                    '${widget.videopath}', // with the String dirPath I have error but if I use the same path but write like this  /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4 it's ok ... why ?
                        (BuildContext
                    context,
                        VideoPlayerController
                        controller) =>
                        AspectRatioVideo(
                            controller: controller)): Center(
                  child:

                  Container(
                    height:MediaQuery.of(context).size.height-60,
                    //  height: 200,
                      child: PhotoView(
                        imageProvider: FileImage(File(widget.filepath),),
                        minScale: PhotoViewComputedScale.contained * 0.2,
                      )
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: (){
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) =>  ChatScreen(cameras: widget.cameras, image: widget.image,name: widget.name,chatmessage: widget.chatmessage, chatid: widget.chatid,)));

                      // Navigator.of(context).pop();
                    },
                    child:Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

}

//Container(
//      height: MediaQuery.of(context).size.height/3,
//      width: MediaQuery.of(context).size.width-200,
//      alignment: Alignment.center,
//      child:
//      widget.type==2? NetworkPlayerLifeCycle(
//          '${widget.videopath}', // with the String dirPath I have error but if I use the same path but write like this  /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4 it's ok ... why ?
//              (BuildContext
//          context,
//              VideoPlayerController
//              controller) =>
//              AspectRatioVideo(
//                  controller: controller)): Image.file(File(widget.filepath),fit: BoxFit.fill,),
//    )

