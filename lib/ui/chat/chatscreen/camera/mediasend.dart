// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../mainscreen/chatscreen.dart';

class CameraSend extends StatefulWidget {
  String? imagePath;
  String? videopath;
  VideoPlayerController? videoController;
 final cameras;
  String name="";
  String image="";
  CameraSend({Key? key,required this.cameras,required this.imagePath,required this.videoController,
    required this.videopath,required this.name,required this.image}) : super(key: key);
  @override
  _CameraSendState createState() {
    return _CameraSendState();
  }
}


class _CameraSendState extends State<CameraSend> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
     widget.videoController?.dispose();
    super.dispose();
  }



  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) =>  ChatScreen(cameras: widget.cameras, image: widget.image,name: widget.name,)));
    // Do some stuff.
    return true;
  }



  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
      Align(
      alignment: Alignment.bottomRight,
        child: Container(
          color: Colors.black,
          margin: EdgeInsets.fromLTRB(5, 5, 5, 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.videoController == null &&  widget.imagePath == null
                  ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,)
                  : SizedBox(
                width: MediaQuery.of(context).size.width-10,
                height: MediaQuery.of(context).size.height-10,
                child: ( widget.videoController == null)
                    ? Image.file(File( widget.imagePath!))
                    : Container(
                  color: Colors.black,
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.pink)),
                  child: Center(
                    child: AspectRatio(
                        aspectRatio:
                        widget.videoController!.value.size != null
                            ?  widget.videoController!.value.aspectRatio
                            : 1.0,
                        child: VideoPlayer( widget.videoController!)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
          _buttonRowWidget()
        ],
      ),
    );
  }
  Widget _buttonRowWidget() {
    return Align(
       alignment: Alignment.bottomRight,
      child: Container(
        color: Colors.black.withAlpha(100),
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(5, 5, 5, 10),
              child: GestureDetector(
                onTap: (){
                  log('tap');
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) =>  ChatScreen(cameras: widget.cameras, imagePath: widget.imagePath, videoController: widget.videoController,
                    videopath: widget.videopath, name: widget.name,image: widget.image,)));

                },
                child: Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                   color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send,color:Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}




