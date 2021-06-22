import 'package:flutter/material.dart';
import 'package:flutter_agora_messenger/flutter_agora_messenger.dart';

import 'calling_page.dart';
import 'configs.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FlutterAgoraMessenger _agoraMessenger = FlutterAgoraMessenger();

  @override
  void initState() {
    super.initState();
    // 远端呼叫事件监听
    _agoraMessenger.setRemoteInvitationReceived((channel, remote, content) {
      // 启动呼叫页面
      print("有新的呼叫邀请");
      Navigator.push(context, MaterialPageRoute(builder: (context) => CallingPage(false, remote)));
    });

    _agoraMessenger.setRemoteInvitationCanceled((channel, remote, content){
      // 远端呼叫被取消
      print("远端呼叫被取消");
      Navigator.pop(context);
    });

    _agoraMessenger.setRemoteInvitationRefused((channel, remote, content) {
      print("远端呼叫被拒绝");
      Navigator.pop(context);
    });

    _agoraMessenger.setRemoteInvitationAccepted((channel, remote, content) {
      Navigator.pop(context);
      print("远端呼叫被接受，开启视频通话页面");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('声网呼叫邀请'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  _agoraMessenger.login(Configs.tmpLocalNumber, Configs.tmpRtmToken).then((r) {
                    print("login result: $r");
                    if (r == "success") {
                      print("登陆成功");
                    } else {
                    }
                  });
                },
                child: Text("登陆")
            ),
            SizedBox(height: 30,),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CallingPage(true, Configs.tmpPeerNumber)));
                },
                child: Text("拨打电话")
            ),
            SizedBox(height: 30,),
            TextButton(
                onPressed: () {
                  _agoraMessenger.logout().then((r) {
                    print("logout result: $r");
                    if (r == "success") {
                      print("登出成功");
                    } else {
                      print("登出失败");
                    }
                  });
                },
                child: Text("退出登陆")
            ),
          ],
        ),
      ),
    );
  }
}