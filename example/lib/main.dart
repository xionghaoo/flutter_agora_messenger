import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_agora_messenger/flutter_agora_messenger.dart';

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
    _agoraMessenger.initial("");
    // 远程呼叫（只在Android端）
    _agoraMessenger.setOnRemoteInvitationReceived((channel, remote) {

    });
    _agoraMessenger.setAnswerCallback((channel, remote) {

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  FlutterAgoraMessenger().login("4321", "006cf309a3e129847bcb31703c7e6283721IAC4NWq547BfVdpG2FIGv+ep2hkVReDsUtTjWFcCaEoi+Gi/jsQAAAAAEACdodgXiiC3YAEA6AMa3bVg").then((r) {
                        print("login result: $r");
                        if (r == "success") {

                        } else {
                        }
                  });
                },
                child: Text("登陆")
            ),
            TextButton(
                onPressed: () {
                  FlutterAgoraMessenger().startOutgoingCall("1234");
                },
                child: Text("拨打电话")
            )
          ],
        ),
      ),
    );
  }
}
