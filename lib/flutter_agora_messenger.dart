
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

  // -----------   ???????????? start   -----------
  /// ???????????????????????????
  setLocalInvitationAccept(LocalInvitationCallback call) {
    _localInvitationAccept = call;
  }

  /// ???????????????????????????
  setLocalInvitationRefused(LocalInvitationCallback call) {
    _localInvitationRefused = call;
  }

  /// ????????????????????????
  setRemoteInvitationReceived(RemoteInvitationCallback call) {
    _remoteInvitationReceived = call;
  }

  /// ???????????????????????????
  setRemoteInvitationCanceled(RemoteInvitationCallback call) {
    _remoteInvitationCanceled = call;
  }

  /// ???????????????????????????
  setRemoteInvitationRefused(RemoteInvitationCallback call) {
    _remoteInvitationRefused = call;
  }

  /// ???????????????????????????
  setRemoteInvitationAccepted(RemoteInvitationCallback call) {
    _remoteInvitationAccepted = call;
  }
  // -----------   ???????????? end   -----------
  
  late final MethodChannel _methodChannel;

  // ----   flutter call native start   ------
  /// ?????????????????????????????????AppId
  initial(String appId) {
    _methodChannel.invokeMethod("initial", {
      "appId": appId
    });
  }

  /// RTM?????????????????????????????????
  Future<String?> login(String account, String token) async {
    return await _methodChannel.invokeMethod("login", {
      "account" : account,
      "token": token
    });
  }

  /// RTM????????????
  Future<String> logout() async {
    return await _methodChannel.invokeMethod("logout");
  }

  /// ????????????
  /// peerNumber: ??????????????????
  Future<String> startOutgoingCall(String peerNumber, String channel, String? content) async {
    return await _methodChannel.invokeMethod("startOutgoingCall", {
      "phoneNumber": peerNumber,
      "channel": channel,
      "content": content
    });
  }

  /// ??????????????????
  /// remote: ??????????????????
  Future<String> hungUp(String remote) async {
    return await _methodChannel.invokeMethod("hungUp", {
      "remote": remote
    });
  }

  /// ????????????????????????
  answerCall() {
    return _methodChannel.invokeMethod("answerCall");
  }

  /// ????????????????????????
  declineCall() {
    return _methodChannel.invokeMethod("declineCall");
  }
  // ----   flutter call native end   ------

}
