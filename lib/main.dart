import 'dart:convert';
import 'dart:io';

import 'package:acs_card_reader_thailand/acs_card_reader_thailand.dart';
import 'package:acs_card_reader_thailand/model/personalInformation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool isCheck_btn = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await AcsCardReaderThailand.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  late PersonalInformation personalInformation =
      PersonalInformation(status: false);

  onConnectDevice() async {
    AcsCardReaderThailand.messageStream.listen((event) async {
      if (event) {
        if (isCheck_btn) {
          isCheck_btn = false;
          setState(() {});
          personalInformation = await AcsCardReaderThailand.acsCardID();
          isCheck_btn = true;
          setState(() {});
        }
      } else {
        isCheck_btn = true;
        personalInformation = PersonalInformation(status: false);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    onConnectDevice();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 9, 63, 90),
            title: const Text(
              'Smart card by The Compete ld.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 9, 63, 90),
                        ),
                      )),
                  Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: personalInformation.status!
                            ? getImagenBase64(
                                personalInformation.PictureSubFix.toString())
                            : Container(
                                height: 150,
                                width: 150,
                                color: Colors.amberAccent,
                              ),
                      ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Text(
                            'เลขประจำตัวประชาชน: ',
                          )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  '${personalInformation.personalID ?? ''} ')),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text('ชื่อ สกุล: ')),
                          Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${personalInformation.nameTH ?? ''} '),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text('${personalInformation.nameEN ?? ''} '),
                                ],
                              )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('เพศ: ')),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  '${personalInformation.gender == 1 ? 'ชาย' : personalInformation.gender == 2 ? 'หญิง' : ''} ')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('เกิดวันที่: ')),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  '${personalInformation.birthDate ?? ''} ')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('วันที่ออกบัตร ')),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  '${personalInformation.IssueDate ?? ''} ')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('วันหมดอายุ: ')),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  '${personalInformation.ExpireDate ?? ''} ')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('ที่อยู่: ')),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  '${personalInformation.address ?? ''} ')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 1,
              ),
              // Text("Message_code -> ${personalInformation.Message_code}"),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 200,
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        personalInformation =
                            await AcsCardReaderThailand.acsCardID();
                        isCheck_btn = true;
                        setState(() {});
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 23, 60, 90),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'READ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          personalInformation =
                              PersonalInformation(status: false);
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'CLEAR',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImagenBase64(String imagen) {
    const Base64Codec base64 = Base64Codec();
    if (personalInformation.status == false)
      return new Container(
        padding: EdgeInsets.all(20),
        color: Colors.grey.shade400,
        child: Icon(
          Icons.person_add,
          size: 100,
          color: Colors.grey.shade500,
        ),
      );

    return Image.memory(
      base64.decode(imagen),
      fit: BoxFit.fitWidth,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();
    path.lineTo(0, h * 0.1);
    path.quadraticBezierTo(w * 0.5, h - 250, w, h * 0.35);
    path.lineTo(w, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Return true if the new clip is different from the old clip
    return true;
  }
}
