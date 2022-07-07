import 'dart:developer';

import 'package:flierdapp/colors/colors.dart';
import 'package:flierdapp/ui/homepage/homepage.dart';
import 'package:flierdapp/utils/string.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MaterialApp(
      theme: ThemeData(fontFamily: "Pangram Sans"),
      debugShowCheckedModeBanner: false, home: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 4 / 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ChatApp,
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
                  Confirmation_that_invitation_has_been_sent,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 1 / 5,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: LinearGradient(
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
                      // Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => QuizPage()));
                    },
                    child: const Text(
                      Continue_Swiping,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    child: Text(
                      Go_to_chat,
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
