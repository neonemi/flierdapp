
import 'package:flierdapp/colors/colors.dart';
import 'package:flierdapp/ui/chat/chatpage/chatpage.dart';
import 'package:flierdapp/ui/chat/chatscreen/mainscreen/chatscreen.dart';

import 'package:flierdapp/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_camera/camera.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  runApp(MaterialApp(
    key: navigatorKey,
      theme: ThemeData(fontFamily: "Pangram Sans"),
      debugShowCheckedModeBanner: false, home:  MyApp(cameras: cameras,)));
}

class MyApp extends StatelessWidget {
  final  cameras;
  MyApp({Key? key,this.cameras}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 4 / 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  appName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  confirmationNote,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 1 / 5,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Colors.transparent,
                      onSurface: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 3,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      fixedSize: const Size(150, 50),
                      //////// HERE
                    ),
                    onPressed: () {
                      // Navigator.pushReplacement(context, MaterialPageRoute(
                      //     builder: (context) => ChatScreen(
                      //       cameras:cameras, image: 'https://dummyimage.com/600x400/5fa9f8/efefef.png&text=User 1', name:'User1', chatid: 1, messagetype: 'receiver',
                      //     )));
                    },
                    child: const Text(
                      continueSwiping,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ChatPage(cameras: cameras,)));
                    },
                    child: const Text(
                      goChat,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
