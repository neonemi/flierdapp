import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../camera/videoplayer.dart';

class Imageview extends StatefulWidget{
  var filepath;
  var type;
  var videopath;
  Imageview({Key? key,required  this.filepath,required this.type,required this.videopath}) : super(key: key);
  @override
  ImageViewState createState() => ImageViewState();

}
class ImageViewState extends State<Imageview>{
  @override
  Widget build(BuildContext context) {
   return Container(
     height: MediaQuery.of(context).size.height/3,
     width: MediaQuery.of(context).size.width-200,
     alignment: Alignment.center,
     child:
     widget.type==2? NetworkPlayerLifeCycle(
         '${widget.videopath}', // with the String dirPath I have error but if I use the same path but write like this  /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4 it's ok ... why ?
             (BuildContext
         context,
             VideoPlayerController
             controller) =>
             AspectRatioVideo(
                 controller: controller)): Image.file(File(widget.filepath),fit: BoxFit.fill,),
   );
  }

}

// Container(
//          //  height: 200,
//            child: Center(
//              child: PhotoViewGallery.builder(
//                backgroundDecoration: BoxDecoration(
//                    color: Colors.white
//                ),
//                scrollPhysics: const BouncingScrollPhysics(),
//                pageController: _pageController,
//                builder: (BuildContext context, int index) {
//                  String myImg =widget.gallery[index];
//                  return PhotoViewGalleryPageOptions(
//                    imageProvider: NetworkImage(myImg),
//                    initialScale: PhotoViewComputedScale.contained * 0.8,
//                    // heroAttributes: PhotoViewHeroAttributes(tag: pics[index].id),
//                  );
//                },
//                itemCount:widget.gallery.length,
//                onPageChanged: (int index) {
//                  setState(() {
//                    firstpage = index;
//                  });
//                },
//              ),
//            )
//            )