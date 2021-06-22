# flutter_agora_messenger
> 声网呼叫邀请SDK

声网的云信令SDK只有android和ios版本的，这里对他们进行了Flutter的封装，可以结合声网视频通话、音频通话还有推送SDK完成音视频通话的功能

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

## 呼叫流程 (A 呼叫 B)

A 调用 ```startOutgoingCall``` 发起呼叫，B 收到 ```remoteInvitationReceived``` 事件：<br/>
    - A 挂断: A收到```localInvitationCanceled```，B 收到 ```remoteInvitationCanceled``` 事件<br/>
    - B 挂断: B收到```remoteInvitationRefused``` ，A 收到 ```localInvitationRefused``` 事件<br/>
    - B 接听: B收到```remoteInvitationAccepted```，A 收到 ```localInvitationAccept``` 事件<br/>

## Demo

修改Configs里面的参数

- ```appId``` 声网的AppId<br/>
- ```tmpRtmToken``` 声网RTM Token，[RTM TOKEN生成文档](https://docs.agora.io/cn/Real-time-Messaging/token_server_rtm?platform=All%20Platforms)<br/>
- ```tmpLocalNumber``` 本机号码<br/>
- ```tmpPeerNumber``` 呼叫号码<br/>