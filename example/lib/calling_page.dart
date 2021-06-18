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
    _agoraMessenger.answerCall();
  }

  _refuse() {
    _agoraMessenger.declineCall();
  }

  @override
  void initState() {
    super.initState();
    if (widget._isOutGoing) {
      _agoraMessenger.setLocalInvitationAccept((channel, remote) {
        // 本地呼叫被接听，开启视频通话页面
        print("本地呼叫被接听，开启视频通话页面");
      });
      _agoraMessenger.setLocalInvitationRefused((channel, remote) {
        print("本地呼叫被拒绝");
        Navigator.pop(context);
      });
      _agoraMessenger.startOutgoingCall(widget._peerId).then((r) {
        if (r == "success") {
          // 等同于LocalInvitationAccept方法回调
        } else {
          print("本地呼叫失败，请检查本机用户是否登陆: $r");
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget._isOutGoing ? "正在呼叫。。。" : "有新的呼叫邀请。。。"),
            SizedBox(height: 20,),
            TextButton(
                onPressed: widget._isOutGoing ? _hungUp : _answer,
                child: Text(widget._isOutGoing ? "挂断" : "接听")
            ),
            SizedBox(height: 10,),
            widget._isOutGoing
                ? SizedBox()
                : TextButton(
                onPressed: _refuse,
                child: Text("挂断")
            )
          ],
        ),
      ),
    );
  }
}