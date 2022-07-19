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
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart' as JustAudio;
import 'package:open_file/open_file.dart';
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
import '../imageview/imageview.dart';

class ChatScreen extends StatefulWidget {
  final cameras;
  String? imagePath;
  String? videopath;
  VideoPlayerController? videoController;
  String name = "";
  String image = "";
  List<ChatMessage>? chatmessage;
  int? chatid;
  String? messagetype;
  ChatScreen(
      {Key? key,
      this.cameras,
      this.videopath,
      this.videoController,
      this.imagePath,
      required this.name,
      required this.image,
      this.chatmessage,
      required this.chatid,
      required this.messagetype})
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
  late JustAudio.AudioPlayer _player;
  CustomPopupMenuController controller = CustomPopupMenuController();
  Uint8List? uint8list;
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = true;
  bool _isPlaying = false;
  AudioPlayer? audioPlayer;
  DateTime time = DateTime.now();
  List<DateTime>? msgtime = [].cast<DateTime>().toList(growable: true);
  Duration durationaudio = const Duration();
  List<ChatMessage>? messages = [].cast<ChatMessage>().toList(growable: true);
  List<String>? message = [].cast<String>().toList(growable: true);
  var loading = false;
  var dirPath;
  var _openResult;
  String strDigits(int n) => n.toString().padLeft(2, '0');
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
          audio: '',
          filepath: '',
          filename: ''));
      _addItem(
          '',
          1,
          1,
          widget.chatid!,
          widget.name,
          1,
          widget.chatid!,
          'sender',
          '',
          widget.videopath!,
          '',
          '',
          '',
          String.fromCharCodes(uint8list!),
          widget.image,
          '',
          DateTime.now().toString());
      // _addItem('', 1, 1,
      //     1, widget.name, 1, 1, 'sender',
      //     '', widget.videopath!, '',  '',  '', Utf8Decoder().convert(uint8list!),widget.image,'');
    });
  }

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
    messages!.add(ChatMessage(
        messagetext: '',
        messageType: 'sender',
        imagepath: '',
        videopath: '',
        messagetime: DateTime.now(),
        uint8list: null,
        videoController: null,
        audio: '',
        filepath: filepath,
        filename: result!.files.first.name));
    _addItem(
        '',
        1,
        1,
        widget.chatid!,
        widget.name,
        1,
        widget.chatid!,
        'sender',
        '',
        '',
        filepath,
        '',
        result.files.first.name,
        '',
        widget.image,
        '',
        DateTime.now().toString());
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
        audio: audiopath!,
        filepath: '',
        filename: ''));
    _addItem(
        '',
        1,
        1,
        widget.chatid!,
        widget.name,
        1,
        widget.chatid!,
        'sender',
        '',
        '',
        '',
        audiopath!,
        '',
        '',
        widget.image,
        '',
        DateTime.now().toString());
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
    final data = await SQLHelper.getItem(widget.chatid!);
    setState(() {
      _chatlist = data;
      _isLoading = false;
    });
  }
//Uint8List x;
// Utf8Decoder().convert(x);
  // Insert a new journal to the database

  Future<void> _addItem(
      String message,
      int messageid,
      int chatDbId,
      int chatid,
      String name,
      int senderid,
      int receiverid,
      String messagetype,
      String imagepath,
      String videopath,
      String filepath,
      String audiopath,
      String filaname,
      String uint8list,
      String profilepic,
      String gifpath,
      String time) async {
    await SQLHelper.createItem(
        message,
        messageid,
        chatDbId,
        chatid,
        name,
        senderid,
        receiverid,
        messagetype,
        imagepath,
        videopath,
        filepath,
        audiopath,
        filaname,
        uint8list,
        profilepic,
        gifpath,
        time);
    _refreshchatlist();
  }

  Future<void> _deleteItem(int receiverid) async {
    await SQLHelper.deleteItem(receiverid);
    _refreshchatlist();
  }

  Future<void> _deleteAllItem() async {
    await SQLHelper.deleteAll();
    _refreshchatlist();
  }

  Future<void> _deletetable() async {
    await SQLHelper.DropTableIfExistsThenReCreate();
    // _refreshchatlist();
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    log(widget.chatid.toString());
    if (widget.chatmessage != null) {
      if (widget.chatmessage!.isNotEmpty) {
        Iterable<ChatMessage> list = List.from(widget.chatmessage!);
        setState(() {
          messages!.addAll(list);
        });
      }
    }
    audioPlayer = AudioPlayer();
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
            audio: '',
            filepath: '',
            filename: ''));
        _addItem(
            '',
            1,
            1,
            widget.chatid!,
            widget.name,
            1,
            widget.chatid!,
            'sender',
            widget.imagePath!,
            '',
            '',
            '',
            '',
            '',
            widget.image,
            '',
            DateTime.now().toString());
      });
    } else if (widget.videopath != null) {
      _videothumbnail();
    }
    // _refreshchatlist();
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

  void urllauch(String path) async {
    final message = await OpenFile.open(path);
    setState(() {
      _openResult = message;
    });
    return;
  }

  Widget _buildLongPressMenu(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 65,
          margin: const EdgeInsets.fromLTRB(12, 0, 20, 0),
          padding:
              const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 10),
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
                                    chatmessage: messages,
                                    chatid: widget.chatid!,
                                    messagetype: widget.messagetype,
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
                        Icons.attach_file_sharp,
                        size: 30,
                        color: ColorConstant.gradient2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 20,
          width: 60,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.fromLTRB(12, 55, 0, 0),
          padding: const EdgeInsets.only(left: 10),
          color: Colors.white,
        ),
      ],
    );
  }

  void updateData(List<ChatMessage> list) {
    setState(() {
      messages!.clear();
      messages!.addAll(list);
    });

    notifyListeners(); // To rebuild the Widget
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    log(_chatlist.toString());
    log(message.toString());
    // log(messages!=null?messages![1].imagepath.toString():'');
    // log(messages!=null?messages![1].messagetext.toString():"");
    log(msgtime.toString());
    log("videopath: ${widget.videopath}");
    log(widget.imagePath.toString());
    log(widget.videoController.toString());
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      body: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        extendBody: false,
        // resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            setState(() {
              visiblity = true;
            });
          },
          child: Container(
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
                                  _deleteItem(widget.chatid!);
                                  // messages!.clear();
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
                  child: _chatlist.isEmpty
                      ? Container(
                          margin: const EdgeInsets.only(top: 100),
                          height: MediaQuery.of(context).size.height - 100,
                          // alignment: Alignment.center
                        )
                      : Container(
                          margin: const EdgeInsets.only(top: 100),
                          height: MediaQuery.of(context).size.height - 100,
                          child: ListView.builder(
                            itemCount: _chatlist.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 10),
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) => Column(
                              children: [
                                if (_chatlist[index]['message'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14, bottom: 14),
                                    child: Align(
                                      alignment: _chatlist[index]
                                                  ['message_type'] ==
                                              'sender'
                                          ? Alignment.topRight
                                          : Alignment.topLeft,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 10),
                                        margin: const EdgeInsets.only(left: 44),
                                        decoration: _chatlist[index]
                                                    ['message_type'] ==
                                                'sender'
                                            ? Styles.boxme
                                            : Styles.boxsomebody,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                DateFormat.jm().format(
                                                    DateFormat("hh:mm").parse(
                                                        '${DateTime.parse(_chatlist[index]['messagetime']).hour.toString()}:${DateTime.parse(_chatlist[index]['messagetime']).minute.toString()} ')),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              (_chatlist[index]['message']),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_chatlist[index]['videopath'].isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder: (BuildContext
                                                          context,
                                                      _,
                                                      __) =>
                                                  Imageview(
                                                    filepath: File(
                                                            _chatlist[index]
                                                                ['videopath'])
                                                        .readAsBytesSync(),
                                                    type: 2,
                                                    videopath: _chatlist[index]
                                                        ['videopath'],
                                                    videoController:
                                                        widget.videoController,
                                                    cameras: widget.cameras,
                                                    name: widget.name,
                                                    chatmessage: messages,
                                                    image: widget.image,
                                                    imagePath: widget.imagePath,
                                                    context: _scaffoldKey
                                                        .currentContext,
                                                    chatid: widget.chatid!,
                                                    messagetype:
                                                        widget.messagetype,
                                                  )));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14, bottom: 14),
                                      child: Align(
                                        alignment: _chatlist[index]
                                                    ['message_type'] ==
                                                'sender'
                                            ? Alignment.topRight
                                            : Alignment.topLeft,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          margin: _chatlist[index]
                                                      ['message_type'] ==
                                                  'sender'
                                              ? const EdgeInsets.only(left: 44)
                                              : const EdgeInsets.only(
                                                  right: 44),
                                          child: Container(
                                            height: 150,
                                            width: 150,
                                            decoration: _chatlist[index]
                                                        ['message_type'] ==
                                                    'sender'
                                                ? Styles.imageboxme
                                                : Styles.imageboxsomebody,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 10,
                                                          bottom: 10),
                                                  child: Text(
                                                      DateFormat.jm().format(
                                                          DateFormat("hh:mm").parse(
                                                              '${DateTime.parse(_chatlist[index]['messagetime']).hour.toString()}:${DateTime.parse(_chatlist[index]['messagetime']).minute.toString()} ')),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Column(children: [
                                                  Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: SizedBox(
                                                        height: 100,
                                                        width: 150,
                                                        child: Image.memory(
                                                          Uint8List.fromList(
                                                              _chatlist[index][
                                                                      'uint8list']
                                                                  .codeUnits),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      )),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_chatlist[index]['audiopath'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 14,
                                        right: 14,
                                        top: 14,
                                        bottom: 14),
                                    child: Align(
                                      alignment: _chatlist[index]
                                                  ['message_type'] ==
                                              'sender'
                                          ? Alignment.topRight
                                          : Alignment.topLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            alignment: _chatlist[index]
                                                        ['message_type'] ==
                                                    'sender'
                                                ? Alignment.topRight
                                                : Alignment.topLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                BubbleNormalAudio(
                                                  isSender: _chatlist[index][
                                                              'message_type'] ==
                                                          'sender'
                                                      ? true
                                                      : false,
                                                  time: DateTime.parse(
                                                      _chatlist[index]
                                                          ['messagetime']),
                                                  textStyle: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                  color: _chatlist[index][
                                                              'message_type'] ==
                                                          'sender'
                                                      ? ColorConstant.deepblue
                                                      : ColorConstant.chatrece,
                                                  duration: durationaudio
                                                      .inSeconds
                                                      .toDouble(),
                                                  position: position.inSeconds
                                                      .toDouble(),
                                                  isPlaying: _isPlaying,
                                                  isLoading: isLoading,
                                                  isPause: isPause,
                                                  onSeekChanged: (value) {},
                                                  onPlayPauseButtonClick: () {
                                                    log(_isPlaying.toString());
                                                    log(isPause.toString());
                                                    setState(() {
                                                      _isPlaying = !_isPlaying;
                                                      isPause = !isPause;
                                                      audioPlayer!
                                                          .onDurationChanged
                                                          .listen((d) =>
                                                              setState(() =>
                                                                  durationaudio =
                                                                      d));
                                                      audioPlayer!
                                                          .onPositionChanged
                                                          .listen((event) =>
                                                              setState(() =>
                                                                  position =
                                                                      event));
                                                    });
                                                    if (_isPlaying == true) {
                                                      audioPlayer!.play(
                                                          BytesSource(File(
                                                                  _chatlist[
                                                                          index]
                                                                      [
                                                                      'audiopath'])
                                                              .readAsBytesSync()));
                                                    } else {
                                                      audioPlayer!.pause();
                                                    }
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
                                if (_chatlist[index]['filepath'].isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      log("tap");
                                      urllauch(_chatlist[index]['filepath']);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14, bottom: 14),
                                      child: Align(
                                        alignment: _chatlist[index]
                                                    ['message_type'] ==
                                                'sender'
                                            ? Alignment.topRight
                                            : Alignment.topLeft,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          margin: _chatlist[index]
                                                      ['message_type'] ==
                                                  'sender'
                                              ? const EdgeInsets.only(left: 44)
                                              : const EdgeInsets.only(
                                                  right: 44),
                                          child: Container(
                                            width: 200,
                                            decoration: _chatlist[index]
                                                        ['message_type'] ==
                                                    'sender'
                                                ? Styles.boxme
                                                : Styles.boxsomebody,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 10,
                                                          bottom: 10),
                                                  child: Text(
                                                      DateFormat.jm().format(
                                                          DateFormat("hh:mm").parse(
                                                              '${DateTime.parse(_chatlist[index]['messagetime']).hour.toString()}:${DateTime.parse(_chatlist[index]['messagetime']).minute.toString()} ')),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Column(children: [
                                                  Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              bottom: 10),
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            _chatlist[index]
                                                                ['filename'],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ))),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_chatlist[index]['imagepath'].isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushReplacement(PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder:
                                            (BuildContext context, _, __) =>
                                                Imageview(
                                          filepath: _chatlist[index]
                                              ['imagepath'],
                                          type: 1,
                                          videopath: '',
                                          videoController:
                                              widget.videoController,
                                          cameras: widget.cameras,
                                          name: widget.name,
                                          chatmessage: messages,
                                          image: widget.image,
                                          imagePath: widget.imagePath,
                                          context: context,
                                          chatid: widget.chatid!,
                                          messagetype: widget.messagetype,
                                        ),
                                      ));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14, bottom: 14),
                                      child: Align(
                                        alignment: _chatlist[index]
                                                    ['message_type'] ==
                                                'sender'
                                            ? Alignment.topRight
                                            : Alignment.topLeft,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          margin: _chatlist[index]
                                                      ['message_type'] ==
                                                  'sender'
                                              ? const EdgeInsets.only(left: 44)
                                              : const EdgeInsets.only(
                                                  right: 44),
                                          child: Container(
                                            height: 150,
                                            width: 150,
                                            decoration: _chatlist[index]
                                                        ['message_type'] ==
                                                    'sender'
                                                ? Styles.imageboxme
                                                : Styles.imageboxsomebody,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 10,
                                                          bottom: 10),
                                                  child: Text(
                                                      DateFormat.jm().format(
                                                          DateFormat("hh:mm").parse(
                                                              '${DateTime.parse(_chatlist[index]['messagetime']).hour.toString()}:${DateTime.parse(_chatlist[index]['messagetime']).minute.toString()} ')),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Column(children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    alignment: _chatlist[index][
                                                                'message_type'] ==
                                                            'sender'
                                                        ? Alignment.topRight
                                                        : Alignment.topLeft,
                                                    child: SizedBox(
                                                      height: 100,
                                                      width: 150,
                                                      child: FadeInImage(
                                                        placeholder: FileImage(
                                                            File(_chatlist[
                                                                    index]
                                                                ['imagepath'])),
                                                        image: MemoryImage(File(
                                                                _chatlist[index]
                                                                    [
                                                                    'imagepath'])
                                                            .readAsBytesSync()),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  )
                                                ]),
                                              ],
                                            ),
                                          ),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: CustomPopupMenu(
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
                              // controller.menuIsShowing=! controller.menuIsShowing;
                            });
                            if (visiblity == false) {
                              controller.showMenu();
                            } else {
                              controller.hideMenu();
                            }
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: visiblity == false
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20))
                                    : const BorderRadius.all(
                                        Radius.circular(20))),
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
                      child: Stack(
                        children: [
                          Container(
                            //height: 80,
                            margin: const EdgeInsets.only(
                              right: 10,
                            ),
                            padding: const EdgeInsets.only(
                              right: 50,
                            ),
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
                              minLines: 1,
                              controller: _messageController,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                hintText: "Write message...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                              ),
                              // keyboardType: TextInputType.text,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    alignment: Alignment.bottomRight,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: const BoxDecoration(
                                        //  color: Colors.transparent,
                                        //   color: Colors.red,
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
                                                  audio: '',
                                                  filepath: '',
                                                  filename: ''));
                                              _addItem(
                                                  _messageController.text,
                                                  1,
                                                  1,
                                                  widget.chatid!,
                                                  widget.name,
                                                  1,
                                                  widget.chatid!,
                                                  'sender',
                                                  '',
                                                  '',
                                                  '',
                                                  '',
                                                  '',
                                                  '',
                                                  widget.image,
                                                  '',
                                                  DateTime.now().toString());
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
                                ],
                              ),
                            ),
                          ),
                        ],
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

//CREATE TABLE chatwindow (key_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,chat_id INTEGER,chat_db_id INTEGER,message_id INTEGER,message TEXT,name TEXT,sender_id INTEGER,receiver_id INTEGER,message_type TEXT,profilepic TEXT,counter INTEGER,
//         createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
//CREATE TABLE messagelist (key_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,chat_id INTEGER,chat_db_id INTEGER,message_id INTEGER,message TEXT,name TEXT,sender_id INTEGER,receiver_id INTEGER,message_type TEXT,imagepath TEXT,videopath TEXT,filepath TEXT,audiopath TEXT,filename TEXT,uint8list TEXT,profilepic TEXT,gifpath TEXT,messagetime TEXT,createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
