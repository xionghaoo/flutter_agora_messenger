import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_agora_messenger/flutter_agora_messenger.dart';
import 'package:flutter_agora_messenger_example/Configs.dart';
import 'package:flutter_agora_messenger_example/calling_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterAgoraMessenger _agoraMessenger = FlutterAgoraMessenger();

  @override
  void initState() {
    super.initState();
    // appid
    _agoraMessenger.initial(Configs.appId);
    // 远程呼叫（只在Android端）
    _agoraMessenger.setOnRemoteInvitationReceived((channel, remote) {
      print("flutter OnRemoteInvitationReceived");
      // 启动呼叫页面
      Navigator.push(context, MaterialPageRoute(builder: (context) => CallingPage(false, remote)));
    });
    _agoraMessenger.setAnswerCallback((channel, remote) {
      // 接听远端呼叫 (ios 端)
    });
    _agoraMessenger.setAnswerCallback((channel, remote) {

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('声网呼叫邀请'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  FlutterAgoraMessenger().login(Configs.tmpLocalNumber, Configs.tmpRtmToken).then((r) {
                        print("login result: $r");
                        if (r == "success") {
                          print("登陆成功");
                        } else {
                        }
                  });
                },
                child: Text("登陆")
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CallingPage(true, Configs.tmpPeerNumber)));
                },
                child: Text("拨打电话")
            )
          ],
        ),
      ),
    );
  }
}
