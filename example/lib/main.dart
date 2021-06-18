import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_agora_messenger/flutter_agora_messenger.dart';
import 'package:flutter_agora_messenger_example/Configs.dart';
import 'package:flutter_agora_messenger_example/calling_page.dart';
import 'package:flutter_agora_messenger_example/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) {
        FlutterAgoraMessenger().initial(Configs.appId);
        return widget!;
      },
      home: HomePage(),
    );
  }
}
