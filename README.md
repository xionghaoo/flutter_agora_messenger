# flutter_agora_messenger_example

声网呼叫邀请SDK
[声网官方文档](https://docs.agora.io/cn/Real-time-Messaging/landing-page?platform=Android)

## 呼叫流程 (A 呼叫 B)

A 调用 startOutgoingCall 发起呼叫，B 收到 remoteInvitationReceived 事件：
    - A 挂断，B 收到 remoteInvitationCanceled 事件
    - B 挂断，A 收到 localInvitationRefused 事件
    - B 接听，A 收到 localInvitationAccept 事件
