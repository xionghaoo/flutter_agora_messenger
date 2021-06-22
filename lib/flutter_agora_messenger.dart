
import 'dart:async';

import 'package:flutter/services.dart';

typedef LocalInvitationCallback(String channel, String remote, String? content);
typedef RemoteInvitationCallback(String channel, String remote, String? content);

class FlutterAgoraMessenger {
  
  static FlutterAgoraMessenger? _instance;
  
  factory FlutterAgoraMessenger() {
    if (_instance == null) {
      final _methodChannel = MethodChannel('flutter_agora_messenger');
      _instance = FlutterAgoraMessenger._(_methodChannel);
    }
    return _instance!;
  }

  LocalInvitationCallback? _localInvitationAccept;
  LocalInvitationCallback? _localInvitationRefused;
  RemoteInvitationCallback? _remoteInvitationReceived;
  RemoteInvitationCallback? _remoteInvitationCanceled;
  RemoteInvitationCallback? _remoteInvitationRefused;
  RemoteInvitationCallback? _remoteInvitationAccepted;

  FlutterAgoraMessenger._(this._methodChannel) {
    // native call flutter
    _methodChannel.setMethodCallHandler((call) {
      print("call: ${call.method}");
      final channel = call.arguments["channel"] as String?;
      final content = call.arguments["content"] as String?;
      final remote = call.arguments["remote"] as String?;
      print("${call.method}: $channel, $remote");
      switch (call.method) {
        case "localInvitationAccept":
          _localInvitationAccept?.call(channel!, remote!, content);
          break;
        case "localInvitationRefused":
          _localInvitationRefused?.call(channel!, remote!, content);
          break;
        case "remoteInvitationReceived":
          _remoteInvitationReceived?.call(channel!, remote!, content);
          break;
        case "remoteInvitationCanceled":
          _remoteInvitationCanceled?.call(channel!, remote!, content);
          break;
        case "remoteInvitationRefused":
          _remoteInvitationRefused?.call(channel!, remote!, content);
          break;
        case "remoteInvitationAccepted":
          _remoteInvitationAccepted?.call(channel!, remote!, content);
          break;
      }
      return Future.value(null);
    });
    
  }

  // -----------   事件回调 start   -----------
  /// 本地呼叫邀请被接受
  setLocalInvitationAccept(LocalInvitationCallback call) {
    _localInvitationAccept = call;
  }

  /// 本地呼叫邀请被拒绝
  setLocalInvitationRefused(LocalInvitationCallback call) {
    _localInvitationRefused = call;
  }

  /// 收到远端呼入邀请
  setRemoteInvitationReceived(RemoteInvitationCallback call) {
    _remoteInvitationReceived = call;
  }

  /// 远端呼入邀请被取消
  setRemoteInvitationCanceled(RemoteInvitationCallback call) {
    _remoteInvitationCanceled = call;
  }

  /// 远端呼入邀请被拒绝
  setRemoteInvitationRefused(RemoteInvitationCallback call) {
    _remoteInvitationRefused = call;
  }

  /// 远端呼入邀请被接受
  setRemoteInvitationAccepted(RemoteInvitationCallback call) {
    _remoteInvitationAccepted = call;
  }
  // -----------   事件回调 end   -----------
  
  late final MethodChannel _methodChannel;

  // ----   flutter call native start   ------
  /// 初始化，填写声网申请的AppId
  initial(String appId) {
    _methodChannel.invokeMethod("initial", {
      "appId": appId
    });
  }

  /// RTM登陆，登录云信令服务器
  Future<String?> login(String account, String token) async {
    return await _methodChannel.invokeMethod("login", {
      "account" : account,
      "token": token
    });
  }

  /// RTM退出登陆
  Future<String> logout() async {
    return await _methodChannel.invokeMethod("logout");
  }

  /// 本地呼叫
  /// peerNumber: 远端用户号码
  Future<String> startOutgoingCall(String peerNumber, String channel, String? content) async {
    return await _methodChannel.invokeMethod("startOutgoingCall", {
      "phoneNumber": peerNumber,
      "channel": channel,
      "content": content
    });
  }

  /// 本地呼叫挂断
  /// remote: 远端用户号码
  Future<String> hungUp(String remote) async {
    return await _methodChannel.invokeMethod("hungUp", {
      "remote": remote
    });
  }

  /// 接受远端呼入电话
  answerCall() {
    return _methodChannel.invokeMethod("answerCall");
  }

  /// 挂断远端呼入电话
  declineCall() {
    return _methodChannel.invokeMethod("declineCall");
  }
  // ----   flutter call native end   ------

}
