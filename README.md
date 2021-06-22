# flutter_agora_messenger
> 声网呼叫邀请SDK

声网的云信令SDK只有android和ios版本的，这里对他们进行了Flutter的封装，可以结合声网视频通话、音频通话还有推送SDK完成音视频通话的功能

***云信令呼叫邀请不支持后台呼叫，需要另外接推送SDK实现后台拉起。***

[声网呼叫邀请官方文档](https://docs.agora.io/cn/Real-time-Messaging/landing-page?platform=Android)

[声网RTM TOKEN生成方式](https://docs.agora.io/cn/Real-time-Messaging/token_server_rtm?platform=All%20Platforms)

[声网视频通话官方Flutter Demo](https://github.com/AgoraIO-Community/Agora-Flutter-Quickstart)

[声网语音通话官方文档](https://docs.agora.io/cn/Voice/start_call_audio_flutter?platform=Flutter)

## 安装方式

1. github
```yaml
flutter_agora_messenger:
    path: ../flutter_agora_messenger
```

2. pub
```yaml
dependencies:
  flutter_agora_messenger: ^x.x.x
```

## 呼叫流程 (A 呼叫 B)

A 调用 ```startOutgoingCall``` 发起呼叫，B 收到 ```remoteInvitationReceived``` 事件：<br/>
    - A 挂断: A收到```localInvitationCanceled```，B 收到 ```remoteInvitationCanceled``` 事件<br/>
    - B 挂断: B收到```remoteInvitationRefused``` ，A 收到 ```localInvitationRefused``` 事件<br/>
    - B 接听: B收到```remoteInvitationAccepted```，A 收到 ```localInvitationAccept``` 事件<br/>

## Demo介绍

1. 修改Configs里面的参数

- ```appId``` 声网的AppId<br/>
- ```tmpRtmToken``` 声网RTM Token，[RTM TOKEN生成文档](https://docs.agora.io/cn/Real-time-Messaging/token_server_rtm?platform=All%20Platforms)<br/>
- ```tmpLocalNumber``` 本机号码<br/>
- ```tmpPeerNumber``` 呼叫号码<br/>

2. 初始化
> 在App启动时初始化，最好在MaterialApp的build方法里面

```dart
FlutterAgoraMessenger().initial(Configs.appId);
```

3. 登陆到声网云信令服务器
```dart
_agoraMessenger.login(Configs.tmpLocalNumber, Configs.tmpRtmToken).then((r) {
    print("login result: $r");
    if (r == "success") {
      print("登陆成功");
    } else {
    }
});
```

4. 在主页面设置远端呼叫事件监听

```dart
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
```

5. 创建呼叫中页面，在呼叫中页面设置事件监听和调用呼叫方法
```dart
if (widget._isOutGoing) {
  _agoraMessenger.setLocalInvitationAccept((channel, remote, content) {
    // 本地呼叫被接听，开启视频通话页面
    print("本地呼叫被接听，开启视频通话页面");
  });
  _agoraMessenger.setLocalInvitationRefused((channel, remote, content) {
    print("本地呼叫被拒绝");
    Navigator.pop(context);
  });
  _agoraMessenger.startOutgoingCall(widget._peerId, "test", "video").then((r) {
    if (r == "success") {
      // 等同于LocalInvitationAccept方法回调
    } else {
      print("本地呼叫失败，请检查本机用户是否登陆: $r");
      Navigator.pop(context);
    }
  });
}
```

