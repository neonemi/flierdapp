import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../colors/colors.dart';
import '../../../main.dart';
import 'chatpagepresenter.dart';
import 'chatpageview.dart';
import '../chatscreen/mainscreen/chatscreen.dart';


class ChatPage extends StatefulWidget {
  final cameras;
  ChatPage({Key? key, this.cameras}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage>
    with ChangeNotifier
    implements ChatPageView {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var chatnotstarted1;
  var chatusers1;
  var chatdata1;
  var userapidata1;
  late ChatPagePresenter _presenter;
  final List<Map<String, String>> listOfColumns = [
    {
      "name": "abc",
      "message": "hi",
    },
    {
      "name": "def",
      "message": "hello",
    },
    {
      "name": "ghi",
      "message": "hi",
    },
    {
      "name": "jkl",
      "message": "hello",
    },
    {
      "name": "mno",
      "message": "hi",
    },
    {
      "name": "pqr",
      "message": "hello",
    },
    {
      "name": "stu",
      "message": "hi",
    },
  ];

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _presenter = ChatPagePresenter(this);
    _presenter.getChatUsers();
    // getChatUsers();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp(
                  cameras: widget.cameras,
                )));
    // Do some stuff.
    return true;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(value)));
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Container(
              padding: const EdgeInsets.only(right: 10),
              child: const Icon(
                Icons.more_horiz,
                color: ColorConstant.deepblue,
                size: 32,
              ))
        ],
      ),
      body: userapidata1 == null
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Stack(
              children: [
                chatnotstarted1 == null
                    ? Container()
                    : Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: chatnotstarted1.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 70,
                                height: 70,
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(70),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  chatnotstarted1[index]
                                                      ['profile_pic_url']),
                                              fit: BoxFit.fill)),
                                      // child: CircleAvatar(
                                      //   backgroundColor: Colors.pink,
                                      //   child: Image.asset("assets/images/dummmy.png",fit: BoxFit.fill),
                                      // ),
                                    ),
                                    Text(
                                      "${chatnotstarted1[index]['name']}",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                  height: 1,
                  child: const Divider(
                    color: Colors.grey,
                  ),
                ),
                chatusers1 == null
                    ? Container()
                    : Container(
                        margin: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                        child: ListView.builder(
                          itemCount: chatusers1.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                              cameras: widget.cameras, image: chatusers1[index][
                                        'profile_pic_url'].toString(), name: chatusers1[index]['name'].toString(), chatid: chatusers1[index]['id'],
                                            )));
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                width: 160,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 10, 0),
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          chatusers1[index][
                                                              'profile_pic_url']),
                                                      // : AssetImage("assets/images/dummy.png"),
                                                      fit: BoxFit.fill)),
                                              child: Container(),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: const Icon(
                                                    Icons
                                                        .remove_red_eye_rounded,
                                                    color: Colors.white,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 170,
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 10, 10, 10),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                //  height: 20,
                                                alignment: Alignment.topRight,
                                                width: 170,
                                                child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.blue),
                                                    child: const Text(
                                                      "1",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      textAlign: TextAlign.end,
                                                    )),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    120,
                                                alignment: Alignment.centerLeft,
                                                child: ListTile(
                                                  title: Text(
                                                    "${chatusers1[index]['name']}",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  subtitle: Text(
                                                    "${listOfColumns[index]['message']}",
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: const Divider(
                                                    color: Colors.grey,
                                                  ))
                                            ]),
                                      ),
                                    ]),
                              ),
                            );
                          },
                        ))
              ],
            ),
      bottomNavigationBar: SizedBox(
          height: 65,
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                  child: Image.asset(
                "assets/images/staricon.png",
                color: ColorConstant.deepblue,
                height: 32,
                width: 32,
              )),
              Center(
                  child: Image.asset(
                "assets/images/avataricon.png",
                color: ColorConstant.lightblue,
                height: 32,
                width: 32,
              )),
              Center(
                child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                        color: ColorConstant.lightblue,
                        borderRadius: BorderRadius.circular(15))),
              ),
              Center(
                  child: Image.asset(
                "assets/images/bubbleicon.png",
                color: ColorConstant.lightblue,
                height: 32,
                width: 32,
              )),
            ],
          )),
    );
  }

  @override
  void chatuser(chatdata, userapidata, chatnotstarted, chatusers) {
    setState(() {
      chatdata1 = chatdata;
      userapidata1 = userapidata;
      chatnotstarted1 = chatnotstarted;
      chatusers1 = chatusers;
    });
  }
}
