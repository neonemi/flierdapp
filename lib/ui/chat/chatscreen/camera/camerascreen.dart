// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flierdapp/ui/chat/chatscreen/camera/mediasend.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../chatscreen.dart';

class CameraApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const CameraApp({Key? key, required this.cameras}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return CameraExampleHome(
      cameras: cameras,
    );
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection? direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;

    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      CameraLensDirection.back;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String? message) =>
    print('Error: $code\nError Message: $message');

class CameraExampleHome extends StatefulWidget {
  var cameras;

  CameraExampleHome({Key? key, required this.cameras}) : super(key: key);
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController? controller;
  String? imagePath;
  late String videoPath;
  VideoPlayerController? videoController;
  late VoidCallback videoPlayerListener;
  bool enableAudio = true;
  FlashMode flashMode = FlashMode.off;
  int selectedCamera = 0;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String minutesStr = '00';
  String secondsStr = '00';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(widget.cameras[selectedCamera]);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackButtonInterceptor.remove(myInterceptor);
    controller?.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  cameras: widget.cameras,
                )));
    // Do some stuff.
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized!) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller!.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                    child: ZoomableWidget(
                        child: _cameraPreviewWidget(),
                        onTapUp: (scaledPoint) {
                          //controller.setPointOfInterest(scaledPoint);
                        },
                        onZoom: (zoom) {
                          print('zoom');
                          if (zoom < 11) {
                            controller!.zoom(zoom);
                          }
                        })),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                      controller != null && controller!.value.isRecordingVideo!
                          ? Colors.redAccent
                          : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          if (controller!.value.isRecordingVideo == true)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Text(
                    '$minutesStr:$secondsStr',
                    style: const TextStyle(color: Colors.red),
                  )),
            )
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized!) {
      return const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: CameraPreview(controller!),
      );
    }
  }

  /// Toggle recording audio
  Widget _toggleAudioWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: <Widget>[
          const Text('Enable Audio:'),
          Switch(
            value: enableAudio,
            onChanged: (bool value) {
              enableAudio = value;
              if (controller != null) {
                onNewCameraSelected(controller!.description);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            videoController == null && imagePath == null
                ? const SizedBox(
                    width: 64.0,
                    height: 64.0,
                  )
                : SizedBox(
                    width: 64.0,
                    height: 64.0,
                    child: (videoController == null)
                        ? Image.file(File(imagePath!))
                        : Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.pink)),
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio:
                                      videoController!.value.size != null
                                          ? videoController!.value.aspectRatio
                                          : 1.0,
                                  child: VideoPlayer(videoController!)),
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Align(
      // alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (widget.cameras.length > 1) {
                  setState(() {
                    selectedCamera =
                        selectedCamera == 0 ? 1 : 0; //Switch camera
                    onNewCameraSelected(widget.cameras[selectedCamera]);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No secondary camera found'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: Container(
                height: 60,
                width: 60,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 30),
                child: const Icon(Icons.cameraswitch, color: Colors.white),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      log('tap');
                      onTakePictureButtonPressed();
                    },
                    onLongPressStart: (value) {
                      log('start');
                      onVideoRecordButtonPressed();
                    },
                    onLongPressEnd: (value) {
                      log('stop');
                      onStopButtonPressed();
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller!.value.isRecordingVideo == true
                            ? Icons.stop
                            : Icons.camera_alt,
                        color: controller!.value.isRecordingVideo == true
                            ? Colors.red
                            : Colors.white,
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 5),
                      child: const Text(
                        "Tap to capture, Press to record",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ))
                ],
              ),
            ),
            const SizedBox(
              width: 64.0,
              height: 64.0,
            )
            // _thumbnailWidget(),
          ],
        ),
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(
      message,
      style: const TextStyle(fontSize: 10),
    )));
  }

  void onNewCameraSelected(CameraDescription? cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(
      cameraDescription!,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String? filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => CameraSend(
                        cameras: widget.cameras,
                        imagePath: filePath,
                        videoController: null,
                        videopath: null,
                      )));

          // showInSnackBar('Picture saved to $filePath');
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String? filePath) {
      if (mounted) {
        setState(() {});
      }
      if (filePath != null) {
        HapticFeedback.vibrate();
        // showInSnackBar('Saving video to $filePath');
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CameraSend(
                      cameras: widget.cameras,
                      imagePath: null,
                      videoController: videoController,
                      videopath: videoPath,
                    )));

        //  showInSnackBar('Video recorded to: $videoPath');
      }
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      //showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  void toogleAutoFocus() {
    controller!.setAutoFocus(!controller!.value.autoFocusEnabled!);
    showInSnackBar('Toogle auto focus');
  }

// Handle timeStream

  Stream<int> stopWatchStream() {
    StreamController<int>? streamController;
    Timer? timer;
    Duration timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter = counter + 1;
      streamController!.add(counter);
      //stopTimer();
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  Future<String?> startVideoRecording() async {
    if (!controller!.value.isInitialized!) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      setState(() {
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
    });

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flierd';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller!.value.isRecordingVideo!) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller!.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo!) {
      return;
    }
    timerSubscription!.cancel();
    timerStream = null;
    setState(() {
      minutesStr = '00';
      secondsStr = '00';
    });
    try {
      await controller!.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }

    await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo!) {
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo!) {
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController!.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String?> takePicture() async {
    if (!controller!.value.isInitialized!) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flierd';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller!.value.isTakingPicture!) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller!.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

//Zoomer this will be a seprate widget
class ZoomableWidget extends StatefulWidget {
  final Widget? child;
  final Function? onZoom;
  final Function? onTapUp;

  const ZoomableWidget({Key? key, this.child, this.onZoom, this.onTapUp})
      : super(key: key);

  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  Matrix4 matrix = Matrix4.identity();
  double zoom = 1;
  double prevZoom = 1;
  bool showZoom = false;
  Timer? t1;

  bool handleZoom(newZoom) {
    if (newZoom >= 1) {
      if (newZoom > 10) {
        return false;
      }
      setState(() {
        showZoom = true;
        zoom = newZoom;
      });

      if (t1 != null) {
        t1!.cancel();
      }

      t1 = Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          showZoom = false;
        });
      });
    }
    widget.onZoom!(zoom);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleStart: (scaleDetails) {
          print('scalStart');
          setState(() => prevZoom = zoom);
          //print(scaleDetails);
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          var newZoom = (prevZoom * scaleDetails.scale);

          handleZoom(newZoom);
        },
        onScaleEnd: (scaleDetails) {
          print('end');
          //print(scaleDetails);
        },
        onTapUp: (TapUpDetails det) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localPoint = box.globalToLocal(det.globalPosition);
          final Offset scaledPoint =
              localPoint.scale(1 / box.size.width, 1 / box.size.height);
          // TODO IMPLIMENT
          // widget.onTapUp(scaledPoint);
        },
        child: Stack(children: [
          Column(
            children: <Widget>[
              Expanded(
                child: widget.child!,
              ),
            ],
          ),
        ]));
  }
}
