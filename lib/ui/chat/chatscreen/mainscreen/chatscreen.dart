import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../colors/colors.dart';
import '../../../../db/db.dart';
import '../../../../model/chatmessage.dart';
import '../../../../utils/style.dart';

import '../../chatpage/chatpage.dart';
import '../camera/audioplayer.dart';
import '../camera/camerascreen.dart';
import '../camera/videoplayer.dart';

class ChatScreen extends StatefulWidget {
  final cameras;
  String? imagePath;
  String? videopath;
  VideoPlayerController? videoController;
  String name = "";
  String image = "";
  ChatScreen(
      {Key? key,
      this.cameras,
      this.videopath,
      this.videoController,
      this.imagePath,
      required this.name,
      required this.image})
      : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with ChangeNotifier {
  final TextEditingController _messageController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _chatlist = [];
  File? _image;
  File? _video;
  final ImagePicker _picker = ImagePicker();
  FilePickerResult? result1;
  var filepath;
  FilePickerResult? result;
  var filename;
  String fileType = 'All';
  var fileTypeList = ['All', 'Image', 'Video', 'Audio', 'MultipleFile'];
  var fileTypegallery = ['Image', 'Video'];
  bool showPlayer = false;
  String? audioPath;
  bool visiblity = true;
  final List<StreamSubscription> _subscriptions = [];
  var audio1;
  CustomPopupMenuController controller = CustomPopupMenuController();
  Uint8List? uint8list;
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  Future<void> _videothumbnail() async {
    load_path_video();
    uint8list = await VideoThumbnail.thumbnailData(
      video: widget.videopath!,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    setState(() {
      messages!.add(ChatMessage(
          messagetext: '',
          messageType: 'sender',
          imagepath: '',
          videopath: widget.videopath!,
          messagetime: DateTime.now(),
          uint8list: uint8list,
          videoController: widget.videoController,
          audio: ''));
    });
  }

  void _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.any);
    setState(() {
      if (result != null) {
        result1 = result;
        result.files.first.name;
        filepath = result.files.first.path;
      }
    });
    if (result == null) return;
    filename = result.files.first.name;
    log(result.files.first.name);
    log(result.files.first.size.toString());
    log(result.files.first.path.toString());
  }

  FilePickerResult? resultaudio;
  String? audiopath;
  String audioname = "";
  void _pickaudio() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.audio);

    setState(() {
      if (result != null) {
        resultaudio = result;
        result.files.first.name;
        audiopath = result.files.first.path;
      }
    });
    messages!.add(ChatMessage(
        messagetext: '',
        messageType: 'sender',
        imagepath: '',
        videopath: '',
        messagetime: DateTime.now(),
        uint8list: null,
        videoController: null,
        audio: audiopath!));
    if (result == null) return;
    audioname = result.files.first.name;
    log(result.files.first.name);
    log(result.files.first.size.toString());
    log(result.files.first.path.toString());
  }

  Future getImagefromcamera() async {
    var image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
    });
    log(_image.toString());
    Navigator.of(context).pop();
  }

  Future getImagefromGallery() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(image!.path);
    });
    log(_image.toString());
    Navigator.of(context).pop();
  }

  Future getVideofromGallery() async {
    var video = await _picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      _video = File(video!.path);
    });
    log(_video.toString());
    Navigator.of(context).pop();
  }

  Future getVideofromCamera() async {
    var video = await _picker.pickVideo(source: ImageSource.camera);

    setState(() {
      _video = File(video!.path);
    });
    log(_video.toString());
    Navigator.of(context).pop();
  }

  void _refreshchatlist() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _chatlist = data;
      _isLoading = false;
    });
  }

  // Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(_messageController.text);
    _refreshchatlist();
  }

  List<ChatMessage>? messages = [].cast<ChatMessage>().toList(growable: true);
  List<String>? message = [].cast<String>().toList(growable: true);
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _refreshchatlist();
    if (widget.imagePath != null) {
      setState(() {
        messages!.add(ChatMessage(
            messagetext: '',
            messageType: 'sender',
            imagepath: widget.imagePath!,
            videopath: '',
            messagetime: DateTime.now(),
            uint8list: null,
            videoController: null,
            audio: ''));
      });
    } else if (widget.videopath != null) {
      _videothumbnail();
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    widget.videoController?.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  cameras: widget.cameras,
                )));
    // Do some stuff.
    return true;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(value)));
  }

  var loading = false;
  var dirPath;

  void load_path_video() async {
    loading = true;
    final Directory extDir = await getApplicationDocumentsDirectory();

    setState(() {
      dirPath = widget.videopath;
      print(dirPath);
      loading = false;
      // if I print ($dirPath) I have /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4
    });
  }

  DateTime time = DateTime.now();
  List<DateTime>? msgtime = [].cast<DateTime>().toList(growable: true);
  AudioPlayer player = AudioPlayer();  //add this
  AudioCache cache = new AudioCache();  //and this
void playaudio(){
  cache.load(audiopath!);
}
  Widget _buildLongPressMenu(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.fromLTRB(12, 0, 20, 0),
      padding: const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: GridView(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, mainAxisSpacing: 5, crossAxisSpacing: 5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            children: [
              Container(
                height: 25,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: ColorConstant.gradient2,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/plusicon.png",
                        color: Colors.white,
                        height: 20,
                        width: 15,
                      ),
                      Image.asset(
                        "assets/images/twodots.png",
                        color: Colors.white,
                        height: 20,
                        width: 15,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraApp(
                                cameras: widget.cameras,
                                name: widget.name,
                                image: widget.image,
                              )));
                },
                child: const SizedBox(
                  height: 30,
                  width: 40,
                  child: Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: ColorConstant.gradient2,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: getImagefromGallery,
                child: Container(
                  height: 25,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ColorConstant.gradient2,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Center(
                    child: Icon(
                      Icons.gif,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: _pickaudio,
                child: const SizedBox(
                  height: 30,
                  width: 30,
                  child: Icon(
                    Icons.mic,
                    size: 30,
                    color: ColorConstant.gradient2,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: _pickFile,
                child: const SizedBox(
                  height: 30,
                  width: 30,
                  child: Icon(
                    Icons.attachment,
                    size: 30,
                    color: ColorConstant.gradient2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    log(_chatlist.toString());
    log(message.toString());
    // log(messages!=null?messages![0].imagepath.toString():"");
    // log(messages!=null?messages![1].messagetext.toString():"");
    log(msgtime.toString());
    log(widget.videopath.toString());
    log(widget.imagePath.toString());
    log(widget.videoController.toString());
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      body: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        // resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            gradient: LinearGradient(
              begin: const Alignment(0.0, 0.0),
              end: const Alignment(0.0, 1.0),
              colors: [
                ColorConstant.palemageta.withAlpha(40),
                ColorConstant.dusk.withAlpha(40),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                height: 90,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(right: 16, left: 8),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatPage(
                                      cameras: widget.cameras,
                                    )));
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          image: DecorationImage(
                              image: NetworkImage(widget.image),
                              fit: BoxFit.fill)),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      offset: const Offset(20, 20),
                      itemBuilder: (BuildContext context) {
                        return List.generate(1, (index) {
                          return PopupMenuItem(
                            child: const Text(
                              "Clear chat",
                              style: TextStyle(color: ColorConstant.deepblue),
                            ),
                            onTap: () {
                              setState(() {
                                message!.clear();
                              });
                            },
                          );
                        });
                      },
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.black54,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                child: messages!.isEmpty
                    ? Container(
                        margin: const EdgeInsets.only(top: 100),
                        height: MediaQuery.of(context).size.height - 100,
                        // alignment: Alignment.center
                      )
                    : Container(
                        margin: const EdgeInsets.only(top: 100),
                        height: MediaQuery.of(context).size.height - 100,
                        child: ListView.builder(
                            itemCount: messages!.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 10),
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) =>
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 14,
                                          right: 14,
                                          top: 14,
                                          bottom: 14),
                                      child: Align(
                                        alignment:
                                            messages![index].messageType ==
                                                    'sender'
                                                ? Alignment.topRight
                                                : Alignment.topLeft,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          margin: EdgeInsets.only(left: 44),
                                          decoration:
                                              messages![index].messageType ==
                                                      'sender'
                                                  ? Styles.boxme
                                                  : Styles.boxsomebody,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "${messages![index].messagetime.hour.toString().padLeft(2, '')}:${messages![index].messagetime.minute.toString().padLeft(2, '')}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              if (messages![index]
                                                  .messagetext
                                                  .isNotEmpty)
                                                Text(
                                                  (messages![index]
                                                      .messagetext),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                  textAlign: TextAlign.left,
                                                ),
                                              if (messages![index]
                                                  .imagepath
                                                  .isNotEmpty)
                                                Column(children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    alignment: messages![index]
                                                                .messageType ==
                                                            'sender'
                                                        ? Alignment.topRight
                                                        : Alignment.topLeft,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: FadeInImage(
                                                        placeholder: FileImage(
                                                            File(messages![
                                                                    index]
                                                                .imagepath)),
                                                        image: const NetworkImage(
                                                            'https://blog.logrocket.com/wp-content/uploads/2021/09/flutter-video-plugin-play-pause.png'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  )
                                                ]),
                                              if (messages![index]
                                                  .videopath
                                                  .isNotEmpty)
                                                Column(children: [
                                                  loading
                                                      ? CircularProgressIndicator()
                                                      : Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          alignment: messages![
                                                                          index]
                                                                      .messageType ==
                                                                  'sender'
                                                              ? Alignment
                                                                  .topRight
                                                              : Alignment
                                                                  .topLeft,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child:
                                                              NetworkPlayerLifeCycle(
                                                                  '$dirPath', // with the String dirPath I have error but if I use the same path but write like this  /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4 it's ok ... why ?
                                                                  (BuildContext
                                                                              context,
                                                                          VideoPlayerController
                                                                              controller) =>
                                                                      AspectRatioVideo(
                                                                         controller: controller)),
                                                        ),
                                                ]),
                                              if (messages![index].audio.isNotEmpty)
                                                Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  alignment: messages![
                                                  index].messageType == 'sender' ? Alignment.topRight : Alignment.topLeft,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      BubbleNormalAudio(
                                                        textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                        color: Colors.grey.shade50,
                                                        duration: duration.inSeconds
                                                            .toDouble(),
                                                        position: position.inSeconds
                                                            .toDouble(),
                                                        isPlaying: isPlaying,
                                                        isLoading: isLoading,
                                                        isPause: isPause,
                                                        onSeekChanged: (value) {},
                                                        onPlayPauseButtonClick: () {
                                                          //playaudio();
                                                        },
                                                        sent: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                        ),

                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 22, bottom: 10, top: 10),
                //height: 80,
                // width: double.infinity,
                color: ColorConstant.dusk.withAlpha(40),
                child: Row(
                  children: <Widget>[
                    CustomPopupMenu(
                      enablePassEvent: true,
                      controller: controller,
                      menuBuilder: () {
                        return _buildLongPressMenu(context);
                      },
                      barrierColor: Colors.transparent,
                      pressType: PressType.singleClick,
                      showArrow: false,
                      verticalMargin: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            visiblity = !visiblity;
                          });
                          if (visiblity == false) {
                            controller.showMenu();
                          } else {
                            controller.hideMenu();
                          }
                        },
                        child: Visibility(
                          visible: visiblity,
                          replacement: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20))),
                            child: Center(
                              child: Container(
                                height: 20,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    begin: Alignment(-0.95, 0.0),
                                    end: Alignment(1.0, 0.0),
                                    colors: [
                                      ColorConstant.gradient2,
                                      ColorConstant.gradient1,
                                    ],
                                    stops: [0.0, 1.0],
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/plusicon.png",
                                        color: Colors.white,
                                        height: 20,
                                        width: 10,
                                      ),
                                      Image.asset(
                                        "assets/images/twodots.png",
                                        color: Colors.white,
                                        height: 10,
                                        width: 10,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Center(
                              child: Container(
                                height: 20,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    begin: Alignment(-0.95, 0.0),
                                    end: Alignment(1.0, 0.0),
                                    colors: [
                                      ColorConstant.gradient2,
                                      ColorConstant.gradient1,
                                    ],
                                    stops: [0.0, 1.0],
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/plusicon.png",
                                        color: Colors.white,
                                        height: 20,
                                        width: 10,
                                      ),
                                      Image.asset(
                                        "assets/images/twodots.png",
                                        color: Colors.white,
                                        height: 10,
                                        width: 10,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                      child: Container(
                        color: Colors.grey.shade100,
                      ),
                    ),
                    Expanded(
                      child: Visibility(
                        visible: visiblity,
                        replacement: Container(
                          // height: 80,
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
                          child: TextField(
                            controller: _messageController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              hintText: "Write message...",
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              suffixIcon: Visibility(
                                visible: visiblity,
                                replacement: Container(
                                  height: 60,
                                  margin:
                                      const EdgeInsets.only(right: 10, top: 10),
                                  //  color: Colors.white,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Container(
                                    height: 60,
                                    padding: const EdgeInsets.all(8),
                                    child: FloatingActionButton(
                                        onPressed: () async {
                                          setState(() {
                                            messages!.add(ChatMessage(
                                                messagetext:
                                                    _messageController.text,
                                                messageType: 'sender',
                                                imagepath: '',
                                                videopath: '',
                                                messagetime: DateTime.now(),
                                                uint8list: null,
                                                videoController: null,
                                                audio: ''));
                                            msgtime!.add(DateTime.now());
                                            _messageController.text = '';
                                          });
                                          _scrollController.animateTo(
                                            0.0,
                                            curve: Curves.easeOut,
                                            duration: const Duration(
                                                milliseconds: 300),
                                          );
                                          //  updateData(message!);
                                          //  await _addItem();
                                        },
                                        backgroundColor: Colors.grey.shade100,
                                        elevation: 0,
                                        child: Container(
                                            padding: const EdgeInsets.all(2),
                                            // height: 50,
                                            width: 30,
                                            child: Image.asset(
                                              "assets/images/sendicon.png",
                                              color: Colors.grey,
                                              height: 30,
                                              width: 30,
                                            ))),
                                  ),
                                ),
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.only(right: 10),
                                  //  color: Colors.white,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: FloatingActionButton(
                                        onPressed: () async {
                                          setState(() {
                                            messages!.add(ChatMessage(
                                                messagetext:
                                                    _messageController.text,
                                                messageType: 'sender',
                                                imagepath: '',
                                                videopath: '',
                                                messagetime: DateTime.now(),
                                                uint8list: null,
                                                videoController: null,
                                                audio: ''));
                                            msgtime!.add(DateTime.now());
                                            _messageController.text = '';
                                          });
                                          // updateData(message!);
                                          // await _addItem();
                                        },
                                        backgroundColor: Colors.grey.shade100,
                                        elevation: 0,
                                        child: Container(
                                            padding: const EdgeInsets.all(2),
                                            //  height: 50,
                                            width: 30,
                                            child: Image.asset(
                                              "assets/images/sendicon.png",
                                              color: Colors.grey,
                                              height: 30,
                                              width: 30,
                                            ))),
                                  ),
                                ),
                              ),
                            ),
                            // keyboardType: TextInputType.text,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.singleLineFormatter
                            ],
                          ),
                        ),
                        child: Container(
                          //height: 80,
                          margin: const EdgeInsets.only(right: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: TextField(
                            minLines: 2,
                            controller: _messageController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              hintText: "Write message...",
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              suffixIcon: Visibility(
                                visible: visiblity,
                                replacement: Container(
                                  height: 60,
                                  margin:
                                      const EdgeInsets.only(right: 10, top: 10),
                                  //  color: Colors.white,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Container(
                                    height: 60,
                                    padding: const EdgeInsets.all(8),
                                    child: FloatingActionButton(
                                        onPressed: () async {
                                          setState(() {
                                            messages!.add(ChatMessage(
                                                messagetext:
                                                    _messageController.text,
                                                messageType: 'sender',
                                                imagepath: '',
                                                videopath: '',
                                                messagetime: DateTime.now(),
                                                uint8list: null,
                                                videoController: null,
                                                audio: ''));
                                            msgtime!.add(DateTime.now());
                                            _messageController.text = '';
                                          });
                                          _scrollController.animateTo(
                                            0.0,
                                            curve: Curves.easeOut,
                                            duration: const Duration(
                                                milliseconds: 300),
                                          );
                                          //  updateData(message!);
                                          //  await _addItem();
                                        },
                                        backgroundColor: Colors.grey.shade100,
                                        elevation: 0,
                                        child: Container(
                                            padding: const EdgeInsets.all(2),
                                            // height: 50,
                                            width: 30,
                                            child: Image.asset(
                                              "assets/images/sendicon.png",
                                              color: Colors.grey,
                                              height: 30,
                                              width: 30,
                                            ))),
                                  ),
                                ),
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.only(right: 10),
                                  //  color: Colors.white,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: FloatingActionButton(
                                        onPressed: () async {
                                          setState(() {
                                            messages!.add(ChatMessage(
                                                messagetext:
                                                    _messageController.text,
                                                messageType: 'sender',
                                                imagepath: '',
                                                videopath: '',
                                                messagetime: DateTime.now(),
                                                uint8list: null,
                                                videoController: null,
                                                audio: ''));
                                            msgtime!.add(DateTime.now());
                                            _messageController.text = '';
                                          });
                                          // updateData(message!);
                                          // await _addItem();
                                        },
                                        backgroundColor: Colors.grey.shade100,
                                        elevation: 0,
                                        child: Container(
                                            padding: const EdgeInsets.all(2),
                                            //  height: 50,
                                            width: 30,
                                            child: Image.asset(
                                              "assets/images/sendicon.png",
                                              color: Colors.grey,
                                              height: 30,
                                              width: 30,
                                            ))),
                                  ),
                                ),
                              ),
                            ),
                            // keyboardType: TextInputType.text,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.singleLineFormatter
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
