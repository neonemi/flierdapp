import 'dart:developer';
import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../colors/colors.dart';
import '../../../db/db.dart';
import '../../../utils/style.dart';
import '../chatpage.dart';
import 'audiorecord/audiorecord.dart';

class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}
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
  File? result1;
  var filepath;
  FilePickerResult? result;
  var filename;
  String fileType = 'All';
  var fileTypeList = ['All', 'Image', 'Video', 'Audio', 'MultipleFile'];
  var fileTypegallery = ['Image', 'Video'];
  bool showPlayer = false;
  String? audioPath;
  bool visiblity=true;
  CustomPopupMenuController controller = CustomPopupMenuController();

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true,type:FileType.any );

    setState(() {
      if (result != null) {
        result1=result as File?;
        result.files.first.name;
        filepath=result.files.first.path;
      }
    });
    if (result == null) return;
    filename = result.files.first.name;
    print(result.files.first.name);
    print(result.files.first.size);
    print(result.files.first.path);
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

  // Update an existing journal
  List<ItemModel> menuItems = [
    ItemModel('copy', Icons.content_copy),
    ItemModel('send', Icons.send),
    ItemModel('collect', Icons.collections),
    ItemModel('delete', Icons.delete),
    ItemModel('Multiple choice', Icons.playlist_add_check),
    ItemModel('quote', Icons.format_quote),
    ItemModel('remind', Icons.add_alert),
    ItemModel('search', Icons.search),

  ];

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
        context, MaterialPageRoute(builder: (context) => const ChatPage()));
    // Do some stuff.
    return true;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(value)));
  }
   camerachooser(BuildContext context) async{
    AlertDialog alertDialog = AlertDialog(
      content:   Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: ColorConstant.lightblue,
                  onPrimary: Colors.white,
                  elevation: 0,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                          color: ColorConstant.lightblue, width: 2)),
                  fixedSize: const Size(165, 50),
                  //////// HERE
                ),
                onPressed: getImagefromcamera,
                child: Text(
                  "Image",
                  style: TextStyle(
                      color:Colors.white,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: ColorConstant.lightblue,
                  onPrimary: Colors.white,
                  elevation: 0,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                          color: ColorConstant.lightblue, width: 2)),
                  fixedSize: const Size(165, 50),
                  //////// HERE
                ),
                onPressed: getVideofromCamera,
                child: Text(
                  "Video",
                  style: TextStyle(
                      color:Colors.white,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ]
        ),

      ),
    );
    showDialog(context: context, builder: (context)=>alertDialog);

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
                        const Text("Record")
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
  Widget _buildLongPressMenu(BuildContext context) {
    return Container(
      height: 65,
      margin: EdgeInsets.fromLTRB(12, 0, 20, 0),
      padding: EdgeInsets.only(left: 10,right: 4,top: 5,bottom: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomRight: Radius.circular(20),topRight: Radius.circular(20) )

      ),
      child: GridView(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
                    Container(child: Image.asset("assets/images/plusicon.png",
                      color: Colors.white,height: 20,width: 15,),),
                    Container(child: Image.asset("assets/images/twodots.png",
                      color: Colors.white,height: 20,width: 15,),)
                  ],
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            GestureDetector(
              onTap:() {

                  camerachooser(context);


               // Navigator.pop(context);
              },
              child: Container(
                height: 30,
                width:40,
                // padding: const EdgeInsets.all(4),
                // alignment: Alignment.center,
                // decoration: BoxDecoration(
                //   color: Colors.blue,
                //   borderRadius: BorderRadius.circular(40),
                // ),
                child: const Icon(
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
                alignment:Alignment.center,
                decoration: BoxDecoration(
                  color: ColorConstant.gradient2,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: const Icon(
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
              onTap: getVideofromCamera,
              child: Container(
                height: 30,
                width:30,
                // padding: const EdgeInsets.all(4),
                // alignment: Alignment.center,
                // decoration: BoxDecoration(
                //   color: Colors.blue,
                //   borderRadius: BorderRadius.circular(40),
                // ),
                child: const Icon(
                  Icons.mic,
                  size: 30,
                  color: ColorConstant.gradient2,
                ),
              ),
            ),
            // Container(
            //   height: 30,
            //   width:30,
            //   child: Center(
            //     child:
            //          AudioRecorder(
            //       onStop: (path) {
            //         if (kDebugMode) print('Recorded file path: $path');
            //         setState(() {
            //           audioPath = path;
            //           showPlayer = true;
            //         });
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
        Column(
          children: [
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 30,
                width:30,
                // padding: const EdgeInsets.all(4),
                // alignment: Alignment.center,
                // decoration: BoxDecoration(
                //   color: Colors.blue,
                //   borderRadius: BorderRadius.circular(40),
                // ),
                child: const Icon(
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
  @override
  Widget build(BuildContext context) {
    log(_chatlist.toString());
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
        key: _scaffoldKey,
       // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 90,
          elevation: 1.0,

          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey.shade100,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16,left: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const ChatPage()));
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

          ),

        ),
        body: Container(
          color:  Colors.grey.shade100,

          child: Stack(children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 22, bottom: 10, top: 10),
                 margin: EdgeInsets.only(top: 100),
                height: 80,
              
                // width: double.infinity,
                color:  Colors.grey.shade100,
                child: Row(
                  children: <Widget>[
                    CustomPopupMenu(
                      enablePassEvent: true,
                      controller: controller,
                      menuBuilder:() {
                      return  _buildLongPressMenu(context);
                      },
                      barrierColor: Colors.transparent,
                      pressType: PressType.singleClick,
                      showArrow: false,

                      verticalMargin: 0,
                      child: GestureDetector(
                         onTap: (){
                           setState(()  {
                             visiblity= !visiblity;
                           });
                           if(visiblity==false){
                             controller.showMenu();
                           }else{
                             controller.hideMenu();
                           }

                         },
                        child: Visibility(
                          visible: visiblity,
                          replacement:  Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))

                            ),
                            child: Center(
                              child: Container(
                                height: 20,
                                width: 30,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient:  LinearGradient(
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
                                      Container(child: Image.asset("assets/images/plusicon.png",color: Colors.white,height: 20,width: 10,),),
                                      Container(child: Image.asset("assets/images/twodots.png",color: Colors.white,height: 10,width: 10,),)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                                borderRadius: BorderRadius.all( Radius.circular(20))

                            ),
                            child: Center(
                              child: Container(
                                height: 20,
                                width: 30,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient:  LinearGradient(
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
                                      Container(child: Image.asset("assets/images/plusicon.png",color: Colors.white,height: 20,width: 10,),),
                                      Container(child: Image.asset("assets/images/twodots.png",color: Colors.white,height: 10,width: 10,),)
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
                          height: 80,
                            margin: const EdgeInsets.only( top: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20))
                          ),
                          child: TextField(
                            controller: _messageController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            maxLines: null,

                            // onChanged: (value){
                            //   _messageController.text=value;
                            // },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),

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
                        child: Container(
                          height: 80,
                        //  margin: const EdgeInsets.only( top: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20))
                          ),
                          child: TextField(
                            controller: _messageController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            maxLines: null,

                            // onChanged: (value){
                            //   _messageController.text=value;
                            // },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),

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
                      ),
                    ),
                 SizedBox(
                      width: 15,
                   child: Visibility(
                     visible: visiblity,
                     replacement: Container(
                        margin: const EdgeInsets.only( top: 10),
                       color: Colors.white,
                     ),
                     child: Container(
                      // margin: const EdgeInsets.only( top: 10),
                       color: Colors.white,
                     ),
                   ),
                    ),
                    Visibility(
                      visible: visiblity,
                      replacement:    Container(
                        margin: EdgeInsets.only(right: 10,top: 10),
                        //  color: Colors.white,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: FloatingActionButton(
                              onPressed: () async {
                                await _addItem();
                              },
                              backgroundColor: Colors.grey.shade100,
                              elevation: 0,
                              child:Container(
                                  padding: EdgeInsets.all(2),
                                  height: 50,width: 30,
                                  child:Image.asset("assets/images/sendicon.png",
                                    color: Colors.grey,height: 30,width: 30,))
                          ),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                      //  color: Colors.white,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: FloatingActionButton(
                            onPressed: () async {
                              await _addItem();
                            },
                            backgroundColor: Colors.grey.shade100,
                            elevation: 0,
                            child:Container(
                                padding: EdgeInsets.all(2),
                                height: 50,width: 30,
                                child:Image.asset("assets/images/sendicon.png",
                                  color: Colors.grey,height: 30,width: 30,))
                          ),
                        ),
                      ),
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
                  : Container(
                margin:EdgeInsets.only(bottom: 80),
                    child: ListView.builder(
                        itemCount: _chatlist.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 10),
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) =>  Column(
                          children: [
                            Container(

                              padding: const EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                              child: Align(
                                alignment: Alignment.topRight,
                                child:Container(
                                  padding: const EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                                  margin: EdgeInsets.only(left: 44),
                                  decoration: Styles.boxme,
                                  child: Text(_chatlist.isNotEmpty?_chatlist[index]['message']:"",
                                    style: const TextStyle(fontSize: 15,color: Colors.white),),
                                ),
                              ),
                            ),
                            Container(

                              padding: const EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child:Container(
                                  padding: const EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                                  margin: EdgeInsets.only(right: 44),
                                  decoration: Styles.boxsomebody,
                                  child: Text(_chatlist.isNotEmpty?"${_chatlist[index]['message']}":"",
                                    style: const TextStyle(fontSize: 15,color: Colors.black),),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
            ),
          ]),
        ));
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
