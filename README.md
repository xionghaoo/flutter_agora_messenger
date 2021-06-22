# flutter_agora_messenger
> 声网呼叫邀请SDK

[声网官方文档](https://docs.agora.io/cn/Real-time-Messaging/landing-page?platform=Android)

## 安装方式

1. github
```yaml
flutter_agora_messenger:
    path: ../flutter_agora_messenger
```

2. pub

## 呼叫流程 (A 呼叫 B)

A 调用 ```startOutgoingCall``` 发起呼叫，B 收到 ```remoteInvitationReceived``` 事件：<br/>
    - A 挂断，B 收到 ```remoteInvitationCanceled``` 事件<br/>
    - B 挂断，A 收到 ```localInvitationRefused``` 事件<br/>
    - B 接听，A 收到 ```localInvitationAccept``` 事件<br/>

## Demo

修改Configs里面的参数

- ```appId``` 声网的AppId<br/>
- ```tmpRtmToken``` 声网RTM Token，[生成文档](https://docs.agora.io/cn/Real-time-Messaging/token_server_rtm?platform=All%20Platforms)<br/>
- ```tmpLocalNumber``` 本机号码<br/>
- ```tmpPeerNumber``` 呼叫号码<br/>