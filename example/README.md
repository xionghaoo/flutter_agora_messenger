# flutter_agora_messenger_example

声网呼叫邀请SDK

## A 呼叫 B

### ios端

A 调用 CallKit::startOutgoingCall，呼叫邀请通走的ios CallKit，同时调用声网rtm sdk，RTM::queryPeerOnline，RTM::sendInvitation，发起呼叫邀请，

B rtm sdk的remoteInvitationReceived方法收到回调，B调用CallKit::showIncomingCall显示来到的拨入电话，点击接受

A 收到CallKit::answerCall回调

### Android端

A 调用声网rtm sdk，调用RTM::queryPeersOnlineStatus，RTM::sendLocalInvitation，发起呼叫邀请，

B rtm sdk的IEventListener::onRemoteInvitationReceived收到回调，调用RTM::acceptRemoteInvitation方法接受呼叫请求，

A 收到IEventListener::onLocalInvitationAccepted回调

## 相关回调事件

呼叫的用户不在线，发生错误
本地呼叫失败，被拒绝


