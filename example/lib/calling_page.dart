import 'package:flutter/material.dart';
import 'package:flutter_agora_messenger/flutter_agora_messenger.dart';

class CallingPage extends StatefulWidget {
  final bool _isOutGoing;
  final String _peerId;
  CallingPage(this._isOutGoing, this._peerId);
  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  FlutterAgoraMessenger _agoraMessenger = FlutterAgoraMessenger();

  _hungUp() {
    FlutterAgoraMessenger().hungUp(widget._peerId).then((r) {
      Navigator.pop(context);
    });
  }

  _answer() {
    FlutterAgoraMessenger().answer().then((r) {
      // 接听远端呼叫
      print("接听远端呼叫");
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget._isOutGoing) {
      _agoraMessenger.setLocalInvitationAccept((channel, remote) {
        // 本地呼叫被接听，开启视频通话页面
        print("本地呼叫被接听，开启视频通话页面");
      });
      _agoraMessenger.startOutgoingCall(widget._peerId);
    }
  }

  @override
  void dispose() {
    if (widget._isOutGoing) {
      _agoraMessenger.endCall(widget._peerId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget._isOutGoing ? "正在呼叫。。。" : "有新的呼叫邀请。。。"),
          SizedBox(height: 20,),
          TextButton(
              onPressed: widget._isOutGoing ? _hungUp() : _answer(),
              child: Text(widget._isOutGoing ? "挂断" : "接听")
          ),
          SizedBox(height: 10,),
          widget._isOutGoing
              ? SizedBox()
              : TextButton(
              onPressed: () {
                // _hungUp();
                // 挂断远端呼叫
                //
              },
              child: Text("挂断")
          )
        ],
      ),
    );
  }
}