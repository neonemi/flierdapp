import 'dart:developer';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


import '../../db/db.dart';
import '../../utils/style.dart';
import '../homepage/homepage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  // VideoPlayerController? _cameraVideoPlayerController;
  // VideoPlayerController? _videoPlayerController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _chatlist = [];
  File? _image;
  File? _video;
  final ImagePicker _picker = ImagePicker();

  Future getImagefromcamera() async {
    var image = await _picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
    });
    log(_image.toString());
    Navigator.of(context).pop();
  }

  Future getImagefromGallery() async {
    var image = await _picker.getImage(source: ImageSource.gallery);

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
    var video = await _picker.getVideo(source: ImageSource.camera);

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

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _messageController.text);
    _refreshchatlist();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshchatlist();
  }

  @override
  void initState() {
    super.initState();

    BackButtonInterceptor.add(myInterceptor);
    _refreshchatlist();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
    // Do some stuff.
    return true;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(value)));
  }

  void chooser(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            getImagefromcamera();
                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => LaunchScreen()));
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text("Camera")
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: getImagefromGallery,
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text("Gallery")
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: getVideofromCamera,
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.video_call,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: getVideofromGallery,
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.video_call,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text("Video Gallery")
                      ],
                    ),
                  ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    log(_chatlist.toString());
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: Colors.white,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 90,
          elevation: 0.0,

          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 16,left: 8),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => const HomePage()));
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const CircleAvatar(
                        // backgroundImage: NetworkImage("<https://randomuser.me/api/portraits/men/5.jpg>"),
                        maxRadius: 20,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Name",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              "Online",
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz,
                        color: Colors.black54,size: 32,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey,),
              ],
            ),

          ),

        ),
        body: Stack(children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      chooser(context);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.black,
                      // onChanged: (value){
                      //   _messageController.text=value;
                      // },
                      decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      await _addItem();
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
          Align(
            child: _chatlist.isEmpty
                ? const Center(
                    // child: CircularProgressIndicator(),
                    )
                : ListView.builder(
                    itemCount: _chatlist.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) =>  Column(
                      children: [
                        Container(

                          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                          child: Align(
                            alignment: Alignment.topRight,
                            child:Container(
                              padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                              decoration: Styles.boxme,
                              child: Text(_chatlist.isNotEmpty?_chatlist[index]['message']:"",
                                style: TextStyle(fontSize: 15,color: Colors.white),),
                            ),
                          ),
                        ),
                        Container(

                          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child:Container(
                              padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                              decoration: Styles.boxsomebody,
                              child: Text(_chatlist.isNotEmpty?_chatlist[index]['message']:"",
                                style: TextStyle(fontSize: 15,color: Colors.black),),
                            ),
                          ),
                        ),
                      ],
                    )),
          ),
        ]));
  }
}
// FadeInImage(
// placeholder: const FileImage(pathToFile),
// image: NetworkImage(uploadedFileUrl),
// fit: BoxFit.cover,
// width: double.infinity,
// height: 256,
// ),

// List<ChatMessage> messages = [
//   ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
//   ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
//   ChatMessage(messageContent: "Hey Kriss, I am doing fine dude. wbu?", messageType: "sender"),
//   ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
//   ChatMessage(messageContent: "Is there any thing wrong?", messageType: "sender"),
// ];
// Align(
//         child: ListView.builder(
//           itemCount: messages.length,
//           shrinkWrap: true,
//           padding: EdgeInsets.only(top: 10,bottom: 10),
//           physics: NeverScrollableScrollPhysics(),
//           itemBuilder: (context, index){
//             return Container(
//               padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
//               child: Align(
//                 alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.blue[200]),
//                   ),
//                   padding: EdgeInsets.all(16),
//                   child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
